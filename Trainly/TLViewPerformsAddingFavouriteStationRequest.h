#import <Foundation/Foundation.h>
#import "TLViewPerformsStationGetInfoRequest.h"
/**
 * This protocol is for view controllers that must prepare
 * data for when they attempt to add a new favourite station
 * @author  Alex Cummaudo
 * @date    2014-04-08
 */
@protocol TLViewPerformsAddingFavouriteStationRequest <NSObject>

@required

/**
 * Success method implemented when data is recieved to 
 * add a new favourite station
 * @param notification  The notification that invoked this
 */
-(void) didSuccessfullyRecieveDataForAddingNewFavouriteStation:(NSNotification*) notification;
/**
 * Failure method implemented for the request trying to add
 * a new favourite station
 * @param notification  The notification that invoked this
 */
-(void) didFailInTryingToGetDataForNewFavouriteStation:(NSNotification*) notification;

@optional

/**
 * Sends a get info request for a train station with the intention
 * that the result of the get info request will be a new favourite
 * station added
 * @param sender  The station I will get info on
 *                (either a name or stop id)
 */
-(void) sendNewFavouriteStationRequest:(id) sender;

@end
