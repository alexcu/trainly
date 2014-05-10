#import <Foundation/Foundation.h>
/**
 * This protocol is for view controllers that must prepare
 * data and display information related to timetables
 * @author  Alex Cummaudo
 * @date    2014-04-08
 */
@protocol TLViewPerformsTimetableRetrievalRequest <NSObject>
/**
 * Success method for loading station data will set up _runTableViewDelegate
 * @param notification  The directions data notification
 */
-(void) didSuccessfullyLoadTimetableData:(NSNotification*) notification;
/**
 * Failure method for unsucessfully loading timetable data
 * @param notification  The error message notification
 */
-(void) didFailLoadTimetableData:(NSNotification*) notification;
@end
