#import <UIKit/UIKit.h>

@class TLTrainStation;

/**
 * This class is a view where the primary information of that view is station
 * information.
 * As such, when initialising this view, use this view's provideViewWithStationData:
 * method to provide the view with station data
 */
@interface TLViewUsesStationData : UIViewController
{
  /// Train station data can either be a TLTrainStation
  TLTrainStation* _trainStationData;
  /// Train station to work from
  NSString* _trainStationName;
}

/**
 * Provides this view with station data
 * @param stationData Either an NSDictionary with required core key/val
 *                    pairs or TLTrainStation.
 */
-(void) provideViewWithStationData:(id) stationData;

/**
 * Determines whether the data provided is valid train station
 * data or not
 * @param   data  The data to validate
 * @return        True if valid, false otherwise
 */
-(BOOL) isValidStationData:(NSDictionary*) data;

/**
 * Determines whether the data provided is a station in Melbourne
 * @param   name  The name to confirm
 * @return        True if valid, false otherwise
 */
-(BOOL) isAStationInMelbourne:(NSString*) name;

@end
