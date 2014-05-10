#import "TLTimetableViewController.h"
#import "TLTrainStation.h"
#import "TLViewLoaderSpinner.h"
#import "TLGenericTableViewDelegateAndDatasource.h"
#import "TLPTVRequest.h"
@interface TLTimetableViewController ()
{
  /// The controller/delegate
  TLGenericTableViewDelegateAndDatasource* _runTableViewDelegate;
}
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationBar;
@property (weak, nonatomic) IBOutlet UITableView *runTableView;
@end

@implementation TLTimetableViewController

#pragma mark - Property Synthesis

@synthesize directionData = _directionData;

#pragma mark - Setup

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self)
  {
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  [_navigationBar setTitle:[_directionData objectForKey:@"direction_name"]];
  
  // Hide while we still load data
  [_runTableView setHidden:YES];
  [[self view] setHidden:NO];
  
  // Show the activity spinner
  [TLViewLoaderSpinner loadSpinnerInView:[self view]];
  
  // Setup selectors
  const SEL SUCCESS_SEL = @selector(didSuccessfullyLoadTimetableData:);
  const SEL FAILURE_SEL = @selector(didFailLoadTimetableData:);
  
  // Load in the station directions from PTV
  [TLPTVRequest requestBroadNextDeparturesForStopID:[_trainStationData valueForKey:@"stopID"]
                                      toDirectionID:_directionData[@"direction_id"]
                                            showAll:NO
                                         successSel:SUCCESS_SEL
                                         failureSel:FAILURE_SEL
                                             sender:self];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

-(void) didFailLoadTimetableData:(NSNotification*) notification
{
  // Kill the spinner
  [TLViewLoaderSpinner stopSpinner];
  NSError* error = [notification userInfo][@"data"];
  
  // Lowercase the first letter in the error desc
  NSString* errorDesc = [[error userInfo] objectForKey:@"NSLocalizedDescription"];
  NSRange firstLetter;
  firstLetter.location = 0;
  firstLetter.length = 1;
  NSString* prettyErrorDesc =
  [errorDesc stringByReplacingCharactersInRange:firstLetter
                                     withString:[[errorDesc substringWithRange:firstLetter] lowercaseString]];
  
  // Setup message to display
  NSString* messageToDisplay = [NSString stringWithFormat:@"Can't get station info since %@", prettyErrorDesc];
  
  // Unwind back to main view with alert message composed...
  UIAlertView* errorAlert = [[UIAlertView alloc] initWithTitle:@"Get Info" message:messageToDisplay
                                                      delegate:nil
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil];
  [errorAlert show];
}

-(void) didSuccessfullyLoadTimetableData:(NSNotification*) notification
{
  // Kill the spinner
  [TLViewLoaderSpinner stopSpinner];
  NSArray* data = [notification userInfo][@"data"];
  
  NSDateFormatter* dateToPrettyStr = [[NSDateFormatter alloc] init];
  [dateToPrettyStr setFormatterBehavior:NSDateFormatterBehavior10_4];
  [dateToPrettyStr setDateStyle:NSDateFormatterNoStyle];
  [dateToPrettyStr setTimeStyle:NSDateFormatterShortStyle];
  
  NSMutableArray* displayableTimes = [[NSMutableArray alloc] init];
  NSInteger rowForClosestTime = 0;

  // Whether we've jumped or not
  BOOL timeSet = NO;
  
  // Now that we have the data, change it to display title...
  for (NSDictionary* timetable in data)
  {
    [displayableTimes addObject:@{@"title":[dateToPrettyStr stringFromDate:timetable[@"departureTime"]],
                                  @"subtitle":timetable[@"expressStatus"]}];
    // Jump to the cell whose closest time matches now---firstly find the closest time to now
    if([timetable[@"departureTime"] timeIntervalSinceNow] > 0 && !timeSet)
    {
      timeSet = YES;
      rowForClosestTime = [data indexOfObject:timetable];
    }
  }
  
  // Assign departure times
  _departureTimes = data;
  
  // Kill the spinner
  [TLViewLoaderSpinner stopSpinner];
  
  // Show while data is there (given was hidden...)
  [_runTableView setHidden:NO];
  
  // Set the directions from the actual train station object itself
  _runTableViewDelegate = [[TLGenericTableViewDelegateAndDatasource alloc]
                                  initWithOneSectionData:displayableTimes
                                  sectionIdentifier:@"PrototypeTimetableTimeCell"];
  [_runTableView setDelegate:self];
  [_runTableView setDataSource:_runTableViewDelegate];
  [_runTableView reloadData];
  
  // Scroll to relevant section closest to time
  [_runTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rowForClosestTime inSection:0]
                       atScrollPosition:UITableViewScrollPositionTop
                               animated:YES];
}

#pragma mark - UITableViewDelegate protocol

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  // Find train departure time
  NSDate* deptTime = [_departureTimes objectAtIndex:[indexPath row]][@"departureTime"];
  // Setup notification on tap
  UILocalNotification* notif = [[UILocalNotification alloc] init];
  
  NSDateFormatter* dateToPrettyStr = [[NSDateFormatter alloc] init];
  [dateToPrettyStr setFormatterBehavior:NSDateFormatterBehavior10_4];
  [dateToPrettyStr setDateStyle:NSDateFormatterNoStyle];
  [dateToPrettyStr setTimeStyle:NSDateFormatterShortStyle];
  
  // Notification body
  NSString* notifBody = [NSString stringWithFormat:@"The %@ %@ has left %@.",
                         [dateToPrettyStr stringFromDate:deptTime],
                         [_directionData objectForKey:@"direction_name"],
                         [_trainStationData name]];
  [notif setAlertBody:notifBody];
  [notif setFireDate:deptTime];
  [[UIApplication sharedApplication] scheduleLocalNotification:notif];
}

@end
