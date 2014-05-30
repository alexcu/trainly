#import "TLViewUsesStationData.h"
#import <UIKit/UIKit.h>
#import "TLViewPerformsTimetableRetrievalRequest.h"
/**
 * The Timetable View Controller displays all trains leaving from
 * the provided train station, and jumps to the very next leaving
 * train in the list of stations
 * @author  Alex Cummaudo
 * @date    2014-04-07
 */
@interface TLTimetableViewController : TLViewUsesStationData <UITableViewDelegate, TLViewPerformsTimetableRetrievalRequest>
{
  /// Departure times (array of NSDates)
  NSArray* _departureTimes;
}
/// The direction in which the view shows timetables for the station
@property NSDictionary* directionData;

@end
