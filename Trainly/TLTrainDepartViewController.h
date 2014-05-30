#import <UIKit/UIKit.h>
#import "TLViewUsesStationData.h"
#import "TLPinStationOnMapViewDelegate.h"
/**
 * The train depart view Controller displays the tapped station where
 * trains leave from
 * @author  Alex Cummaudo
 * @date    2014-05-27
 */
@interface TLTrainDepartViewController : TLViewUsesStationData
{
  TLPinStationOnMapViewDelegate* _displayStationDelegate;
}
@property NSDate* departureTime;

@end
