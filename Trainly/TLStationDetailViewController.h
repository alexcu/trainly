#import <UIKit/UIKit.h>
#import "TLPinStationOnMapViewDelegate.h"
#import "TLViewUsesStationData.h"
#import "TLViewPerformsStationGetInfoRequest.h"

// Import Frameworks
#import <MapKit/MapKit.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import <MessageUI/MessageUI.h>

/**
 * The station detail view controller lists all detailed information regarding
 * a station, and allows social sharing and miscellaneous options on the provided
 * station, such as opening the station on PTV's website or sharing on Facebook.
 * @author  Alex Cummaudo
 * @date    2014-03-30
 */
@interface TLStationDetailViewController : TLViewUsesStationData
  <TLViewPerformsStationGetInfoRequest, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, UIAlertViewDelegate>
{
  TLPinStationOnMapViewDelegate* _displayStationDelegate;
}

@end
