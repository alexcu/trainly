#import "TLStationDetailViewController.h"
#import "TLViewLoaderSpinner.h"
#import "TLTrainStation.h"
#import "TLSearchForStationViewController.h"
#import "TLPTVRequest.h"
@interface TLStationDetailViewController()
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
/**
 * Brings up the composer sheet for shaing to a social network
 * @param socialNetwork Use SLServiceType enum for easy access to social network types
 */
-(void) shareOnSocialNetwork:(NSString*) socialNetwork;
/**
 * Shares the station via email
 */
-(void) shareViaEmail;
/**
 * Begins loading data for the station provided
 */
-(void) beginLoadingData;
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
    [self beginLoadingData];
  }
}

-(void) beginLoadingData
{
  // Hide the other things
  [_stationNameButton setHidden:YES];
  [_stationLocationMap setHidden:YES];
  [_bottomBar setHidden:YES];
  
  // Show please wait...
  [TLViewLoaderSpinner loadSpinnerInView:[self view]];
  
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

  // Stop listening
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  
  // Add in the new station...
  NSDictionary* gotInfoForThisStation = data[0];
  // Therefore we can supplement station data with this info!
  [self provideViewWithStationData:gotInfoForThisStation];

  // Unhide the stuff
  [_stationNameButton setHidden:NO];
  [_stationLocationMap setHidden:NO];
  [_bottomBar setHidden:NO];
  
  // Kill the spinner
  [TLViewLoaderSpinner stopSpinner];
  
  // Enough info to proceed...
  [self didRecieveAllDataNeeded];
}

-(void) didFailSendingGetInfoRequest:(NSNotification *)notification
{
  NSError* error = [notification userInfo][@"data"];
  
  // Stop listening
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
  UIAlertView* errorAlert = [[UIAlertView alloc] initWithTitle:@"Get Info" message:messageToDisplay
                                                      delegate:nil
                                             cancelButtonTitle:@"Cancel"
                                             otherButtonTitles:@"Retry", nil];
  [errorAlert show];
  [errorAlert setDelegate:self];
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

#pragma mark - Sharing

-(IBAction)actionSheet:(id)sender
{
  UIActionSheet* sheet = [[UIActionSheet alloc]
                          initWithTitle:nil
                          delegate:self
                          cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Share on Facebook", @"Share on Twitter", @"Share via Email", @"Open in Maps", @"Open in Safari", nil];
  [sheet showInView:[self view]];
}

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
  switch (buttonIndex)
  {
    // Facebook
    case 0:
      [self shareOnSocialNetwork:SLServiceTypeFacebook];
      break;
    // Twitter
    case 1:
      [self shareOnSocialNetwork:SLServiceTypeTwitter];
      break;
    // Email
    case 2:
      [self shareViaEmail];
      break;
    // Open in Apple Maps
    case 3:
      [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[_trainStationData generateMapURL]]];
      break;
    // Open in Safari
    case 4:
      [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[_trainStationData generatePTVOpenURL]]];
      break;
    default:
      break;
  }
}

-(void) shareOnSocialNetwork:(NSString*) socialNetwork;
{
  // com.apple.social.<network>
  NSString* networkName = [[socialNetwork componentsSeparatedByString:@"."][3] capitalizedString];
  
  // Setup default message
  NSString* defaultMessageToPost =
    [NSString stringWithFormat:@"Check out %@ Station, it rocks! %@", [_trainStationData name], [_trainStationData generatePTVOpenURL]];
  // Setup default image to post (map view image)
  UIGraphicsBeginImageContext(_stationLocationMap.frame.size);
  // Render the map's layer in a new context (social)
  CGContextRef social = UIGraphicsGetCurrentContext();
  [_stationLocationMap.layer renderInContext:social];
  // Scoop out the image we just rendered
  UIImage* defaultImageToPost = UIGraphicsGetImageFromCurrentImageContext();
  // Return back to default context
  UIGraphicsEndImageContext();
  
  // Check if we can send facebook requests
  if ([SLComposeViewController isAvailableForServiceType:socialNetwork])
  {
    // Setup the view
    SLComposeViewController* socialVC = [[SLComposeViewController alloc] init];
    socialVC = [SLComposeViewController composeViewControllerForServiceType:socialNetwork];
    [socialVC setInitialText:defaultMessageToPost];
    [socialVC addImage:defaultImageToPost];
    // Handler for callback (based on provided result)
    SLComposeViewControllerCompletionHandler handler = ^(SLComposeViewControllerResult result)
    {
      NSString* msg;
      // Informative message that post was made
      if (result == SLComposeViewControllerResultDone)
      {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Share"
                                                        message:msg
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
      }
    };
    // Now setup handler callbacks
    [socialVC setCompletionHandler:handler];
    // Show the view
    [self presentViewController:socialVC animated:YES completion:nil];
  }
  else
  {
    // Message that account has not been set up.
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Share"
                                                    message:[NSString stringWithFormat:@"%@ hasn't been set up on this device.", networkName]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
  }
}

-(void) shareViaEmail;
{
  MFMailComposeViewController* emailVC = [[MFMailComposeViewController alloc] init];
  [emailVC setSubject:[_trainStationData name]];
  NSString* defaultBody =
  [NSString stringWithFormat:@"Check out %@ station, it rocks!<br/><a href=\"%@\">%@</a>", [_trainStationData name], [_trainStationData generatePTVOpenURL], [_trainStationData generatePTVOpenURL]];
  [emailVC setMessageBody:defaultBody isHTML:YES];
  [emailVC setMailComposeDelegate:self];
  // Show the view
  [self presentViewController:emailVC animated:YES completion:nil];
}

-(void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
  // Dismiss the view
  [self dismissViewControllerAnimated:YES completion:NULL];
}



@end