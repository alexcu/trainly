#import "TLStationDetailViewController.h"
#import "TLViewLoaderSpinner.h"
#import "TLTrainStation.h"
#import <MapKit/MapKit.h>
#import "TLSearchForStationViewController.h"
#import "TLPTVRequest.h"

@interface TLStationDetailViewController()
{
  /// Please wait spinner...
  TLViewLoaderSpinner* _pleaseWaitSpinner;
}
/// The location map
@property (weak, nonatomic) IBOutlet MKMapView  *stationLocationMap;
/// The big name button
@property (weak, nonatomic) IBOutlet UIButton   *stationNameButton;
/// Bottom share toolbar
@property (weak, nonatomic) IBOutlet UIToolbar *bottomBar;
/**
 * Call this method to unhide all elements and display the map
 */
- (void) didRecieveAllDataNeeded;
@end

@implementation TLStationDetailViewController

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
  // Was I given station info to work with?
  if (_trainStationData)
    [self didRecieveAllDataNeeded];
  // Otherwise, I'll need to load info based on what I have so far...
  else
  {
    // Hide the other things
    [_stationNameButton setHidden:YES];
    [_stationLocationMap setHidden:YES];
    
    // Show please wait...
    _pleaseWaitSpinner = [TLViewLoaderSpinner loadSpinnerInView:[self view]];
    
    // Load in the station with the info I do have...
    const SEL successSelector = @selector(didSuccessfullyRecieveDataForGettingInfo:);
    const SEL failureSelector = @selector(didFailSendingGetInfoRequest:);
    // In order to add the new favourite station, I need to know more about it---
    // for me to know more about it I'll need to send a get info request...
    [TLPTVRequest requestStationSearch:_trainStationName
                            successSel:successSelector
                            failureSel:failureSelector
                                sender:self];
  }
}


- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void) didRecieveAllDataNeeded
{
  // Load in the station name to title
  [_stationNameButton setTitle:[_trainStationData valueForKey:@"name"] forState:UIControlStateNormal];
  
  // Initialise the map delegate
  _displayStationDelegate = [[TLPinStationOnMapViewDelegate alloc] init];
  
  // Pass in the station info
  [_displayStationDelegate provideViewWithStationData:_trainStationData];
  [_stationLocationMap setDelegate:_displayStationDelegate];
}

#pragma mark - Button Interaction

- (IBAction)stationNameTapped:(id)sender
{
  // Refocus the centrepoint of the map back on the station
  [_displayStationDelegate focusCentrepointForMapView:_stationLocationMap];
}

#pragma mark - TLViewPerformsStationGetInfoRequest Protocol Implementation

-(void) didSuccessfullyRecieveDataForGettingInfo:(NSNotification *)notification
{
  NSArray* data  = [notification userInfo][@"data"];
  // Add in the new station...
  NSDictionary* gotInfoForThisStation = data[0];
  // Therefore we can supplement station data with this info!
  [self provideViewWithStationData:gotInfoForThisStation];

  // Unhide the stuff
  [_stationNameButton setHidden:NO];
  [_stationLocationMap setHidden:NO];
  
  // Kill the spinner
  [_pleaseWaitSpinner stopSpinner];
  
  // Enough info to proceed...
  [self didRecieveAllDataNeeded];
}

-(void) didFailSendingGetInfoRequest:(NSNotification *)notification
{
  NSError* error = [notification userInfo][@"error"];
  
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
  [_pleaseWaitSpinner stopSpinner];
  
  // Unwind back to main view with alert message composed...
  UIAlertView* errorAlert = [[UIAlertView alloc] initWithTitle:@"Get Info" message:messageToDisplay
                                                      delegate:nil
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil];
  [errorAlert show];
}



@end