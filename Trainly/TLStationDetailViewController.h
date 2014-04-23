#import <UIKit/UIKit.h>
#import "TLPinStationOnMapViewDelegate.h"
#import "TLViewUsesStationData.h"
#import "TLViewPerformsStationGetInfoRequest.h"
/**
 * @author  Alex Cummaudo
 * @date    2014-03-30
 */
@interface TLStationDetailViewController : TLViewUsesStationData
  <TLViewPerformsStationGetInfoRequest>
{
  TLPinStationOnMapViewDelegate* _displayStationDelegate;
}

@end
