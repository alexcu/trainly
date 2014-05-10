#import "TLViewUsesStationData.h"
#import <UIKit/UIKit.h>
#import "TLViewPerformsTimetableRetrievalRequest.h"
@interface TLTimetableViewController : TLViewUsesStationData <UITableViewDelegate, TLViewPerformsTimetableRetrievalRequest>
{
  /// Departure times (array of NSDates)
  NSArray* _departureTimes;
}
/// The direction in which the view shows timetables for the station
@property NSDictionary* directionData;

@end
