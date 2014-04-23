#import <Foundation/Foundation.h>

// Forward declare
@class TLTrainStation;
@class TLURLRequest;

/**
 * This class handles all requests made to the PTV
 * API backend. Use this class for all requests needed
 * @author  Alex Cummaudo
 * @date    2014-03-23
 */
@interface TLPTVRequest : NSObject
{
  /// The keyword for NSNotificationCentre invocation when healthchecks have finished successfully
  NSString* _requestKeyword;
  /// The selector of the desired internal request
  SEL _requestSelector;
  /// The request parameters stored for multithreading
  NSDictionary* _requestUserInfo;
  /// Parameters to be used once data is recieved on request
  NSDictionary* _requestParseParams;
  /// The TLURLRequest this TLPTVRequest embeds (NOT healthcheck
  /// request, but the actual request)
  TLURLRequest* _internalRequest;
  /// The healthcheck status
  BOOL _performingHealthcheck;
}

/// Percentage loaded from this request
@property (readonly) float percentageLoaded;

/**
 * Convenience constructor for requesting station searches from the PTV API
 * @param query           The station name to query the PTV Database
 * @param successSelector The selector to be executed with the data on success
 * @param failureSelector The selector to be executed with an error on failure
 * @discussion
 *  The success and failure selectors will both require exactly one argument
 *  as their first arguments of type NSNotification. The userInfo of the notification
 *  will contain the returned data or the error to work with should there be one.
 *  In the case of this request, the data returned will be an NSArray of
 *  NSDictionaries which contain station data of the query that has been specified.
 * @return  A new TLPTVRequest
 */
+(id) requestStationSearch:(NSString*) query
                successSel:(SEL) successSelector
                failureSel:(SEL) failureSelector
                    sender:(id) sender;
/**
 * Convenience constructor for requesting the broad next departures for a station with
 * the given stop identifier
 * @param stopID          The station stopID to query broad next departures from
 *                        the PTV Database
 * @param dirID           Get the stops going in this direction
 * @param showAll         Whether or not all departures should be shown and loaded
 * @param successSelector The selector to be executed with the data on success
 * @param failureSelector The selector to be executed with an error on failure
 * @discussion
 *  The success and failure selectors will both require exactly one argument
 *  as their first arguments of type NSNotification. The userInfo of the notification
 *  will contain the returned data or the error to work with should there be one.
 *  In the case of this method, multiple NSDictionaries containing the broad
 *  next departures will be returned in an NSArray
 * @return  A new TLPTVRequest
 */
+(id) requestBroadNextDeparturesForStopID:(NSNumber*) stopID
                            toDirectionID:(NSNumber*) dirID
                                  showAll:(BOOL) showAll
                               successSel:(SEL) successSelector
                               failureSel:(SEL) failureSelector
                                   sender:(id) sender;
/**
 * Convenience constructor for requesting the broad next departures for a station with
 * the given stop identifier
 * @param stopID          The station stopID to query lines for
 * @param showAll         Whether or not all departures should be shown and loaded
 * @param successSelector The selector to be executed with the data on success
 * @param failureSelector The selector to be executed with an error on failure
 * @discussion
 *  The success and failure selectors will both require exactly one argument
 *  as their first arguments of type NSNotification. The userInfo of the notification
 *  will contain the returned data or the error to work with should there be one.
 *  In the case of this method, multiple NSDictionaries containing the lines
 *  this stop runs to will be returned in an NSArray
 * @return  A new TLPTVRequest
 */
+(id) requestLinesForStopID:(NSNumber*) stopID
                 successSel:(SEL) successSelector
                 failureSel:(SEL) failureSelector
                     sender:(id) sender;
/**
 * Flushes all still-active requests initiated by PTV request objects
 */
+(void) flushRequests;

@end