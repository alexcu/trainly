#import <UIKit/UIKit.h>
#import "TLViewUsesStationData.h"
#import "TLViewPerformsTimetableRetrievalRequest.h"

/**
 * The Station Direction View Controller lists all the directions
 * in which trains leave towards from the provided train station
 * @author  Alex Cummaudo
 * @date    2014-03-28
 */
@interface TLStationDirectionViewController : TLViewUsesStationData
<UIAlertViewDelegate, TLViewPerformsTimetableRetrievalRequest>
{
  /// The directions info loaded from the request
  NSArray* _directionInfo;
}
@end
