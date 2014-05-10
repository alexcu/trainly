#import <UIKit/UIKit.h>
#import "TLViewUsesStationData.h"
#import "TLViewPerformsTimetableRetrievalRequest.h"
@interface TLStationDirectionViewController : TLViewUsesStationData
<UIAlertViewDelegate, TLViewPerformsTimetableRetrievalRequest>
{
  /// The directions info loaded from the request
  NSArray* _directionInfo;
}
@end
