#import <Foundation/Foundation.h>
/**
 * This protocol is for view controllers that must prepare
 * data and display information related to stations
 * @author  Alex Cummaudo
 * @date    2014-04-08
 */
@protocol TLViewPerformsStationGetInfoRequest <NSObject>

@required

/**
 * Success method implemented for getting train info
 * @param notification  The notification that invoked this
 */
-(void) didSuccessfullyRecieveDataForGettingInfo:(NSNotification*) notification;
/**
 * Failure method implemented for getting train info
 * @param notification  The notification that invoked this
 */
-(void) didFailSendingGetInfoRequest:(NSNotification*) notification;

@optional

/**
 * Sends a get info request for a train station
 * @param sender  The station I will get info on
 *                (either a name or stop id)
 */
-(void) sendGetInfoRequestForStation:(id) sender;

@end
