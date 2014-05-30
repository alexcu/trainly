#import "TLStationDirectionViewController.h"
#import "TLTrainStation.h"
#import "TLGenericTableViewDelegateAndDatasource.h"
#import "TLPTVRequest.h"
#import "TLViewLoaderSpinner.h"
#import "TLTimetableViewController.h"

@interface TLStationDirectionViewController ()
{
  /// The table view delegate for the directions
  TLGenericTableViewDelegateAndDatasource* _directionsTableViewDelegate;
}
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationBar;
@property (strong, nonatomic) IBOutlet UITableView *directionsTableView;
/**
 * Begins loading data for the station provided
 */
-(void) beginLoadingData;
@end

@implementation TLStationDirectionViewController

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

  [_navigationBar setTitle:[_trainStationData valueForKey:@"name"]];
  [self beginLoadingData];
}

-(void) beginLoadingData
{
  // Hide while we still load data
  [_directionsTableView setHidden:YES];
  [[self view] setHidden:NO];
  
  // Show the activity spinner
  [TLViewLoaderSpinner loadSpinnerInView:[self view]];
  
  // Setup selectors
  const SEL SUCCESS_SEL = @selector(didSuccessfullyLoadTimetableData:);
  const SEL FAILURE_SEL = @selector(didFailLoadTimetableData:);
  
  // Load in the station directions from PTV
  [TLPTVRequest requestLinesForStopID:[_trainStationData valueForKey:@"stopID"]
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

  [[NSNotificationCenter defaultCenter] removeObserver:self];
  
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
  
  // Kill the spinner
  [TLViewLoaderSpinner stopSpinner];
  
  // Display retry error alert
  UIAlertView* errorAlert = [[UIAlertView alloc] initWithTitle:@"Get Timetable" message:messageToDisplay
                                                      delegate:nil
                                             cancelButtonTitle:@"Cancel"
                                             otherButtonTitles:@"Retry", nil];
  [errorAlert show];
  [errorAlert setDelegate:self];
}

-(void) didSuccessfullyLoadTimetableData:(NSNotification*) notification
{
  // Kill the spinner
  NSArray* data = [notification userInfo][@"data"];
  
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  
  // Set the directions info
  _directionInfo = data;
  
  // Now that we have the data, change it to display title...
  NSMutableArray* displayableDirections = [[NSMutableArray alloc] init];
  for (NSDictionary* direction in data)
    [displayableDirections addObject:@{@"title":[NSString stringWithFormat:@"To %@", direction[@"direction_name"]]}];
  
  // Kill the spinner
  [TLViewLoaderSpinner stopSpinner];
  
  // Show while data is there (given was hidden...)
  [_directionsTableView setHidden:NO];
  
  // Set the directions from the actual train station object itself
  _directionsTableViewDelegate = [[TLGenericTableViewDelegateAndDatasource alloc]
                                  initWithOneSectionData:displayableDirections
                                  sectionIdentifier:@"PrototypeStationDirectionCell"];
  [_directionsTableView setDelegate:_directionsTableViewDelegate];
  [_directionsTableView setDataSource:_directionsTableViewDelegate];
  [_directionsTableView reloadData];
}

#pragma mark - UIAlertViewDelegate

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
  // Retry
  if (buttonIndex == 1)
    [self beginLoadingData];
  // Cancel
  if (buttonIndex == 0)
    [self performSegueWithIdentifier:@"failedToGetStationInfo" sender:self];
}

#pragma mark - Navigation

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  // Provide in the departure id number
  if ([[segue identifier] isEqualToString:@"getDepartureInfo"])
  {
    // Get relevant direction info for the selected row to next view
    NSInteger selectedRow = [[_directionsTableView indexPathForCell:sender] row];
    NSDictionary* direction =
      [_directionInfo objectAtIndex:selectedRow];
    [[segue destinationViewController] setDirectionData:direction];
    [[segue destinationViewController] provideViewWithStationData:_trainStationData];
  }
}

@end
