#import "TLPTVRequest.h"
#import "TLURLRequest.h"
#import "TLPTVURLGenerator.h"

/// The list of active PTV requests that are currently fetching data
static NSMutableArray* activeRequests;

@interface TLPTVRequest();

#pragma mark - Initialisers

/**
 * Generic convenience constructor for setting and invoking the new
 * TLPTVRequest
 * @param requestKeyword  The keyword to bind this request to
 * @param requestSelector The internal request selector to call
 * @param requestUserInfo The data to pass to the internal request selector
 * @param successSelector The success selector to call on the sender on request success
 * @param failureSelector The failure selector to call on the sender on request failure
 * @param sender          The invoker of this request
 */
+(id) requestWithRequestKey:(NSString*) requestKey
            requestSelector:(SEL) requestSelector
            requestUserInfo:(NSDictionary*) requestUserInfo
            successSelector:(SEL) successSelector
            failureSelector:(SEL) failureSelector
                     sender:(id) sender;
/**
 * Initialiser for a TLPTVRequest instance with the given request
 * keyword to bond to it
 * @param requestKeyword  The keyword to bind this request to
 * @param requestSelector The internal request selector to call
 * @param requestUserInfo The data to pass to the internal request selector
 */
-(id) initWithRequestKeyword:(NSString*) requestKeyword
             requestSelector:(SEL) requestSelector
             requestUserInfo:(NSDictionary*) requestUserInfo;

#pragma mark - Helpers Definitions
/**
 * Sets up NSNotificationCenter observations on the given observer (external!!)
 * for the request keyword for success and failure. Use this in the
 * convenience constructors to initiate the requests and set up their
 * callback methods
 * @param requestKeyword  The keyword to tie this request to
 * @param successSelector Selector to invoke on observer on success of the request
 * @param failureSelector Selector to invoke on observer on failure of the request
 * @param observer        The observer the notification will be pushed to
 */
+(void) setupNotificationObservationForKeyword:(NSString*) requestKeyword
                               successSelector:(SEL) successSelector
                               failureSelector:(SEL) failureSelector
                                      observer:(id) observer;
/**
 * Posts a success notificiation with data to observers
 * @param data  The data to post success with
 */
-(void) postSuccessNotificationWithData:(id) data;
/**
 * Posts a failure notificiation with data to observers
 * @param data  The data to post success with
 */
-(void) postFailureNotificationWithError:(id) error;
/**
 * Failure callback for all internal requests invoked
 * using internalRequestWithURL:successCallback:
 * @param notification  The notification back from this request failure
 */
-(void) internalRequestFailureCallback:(NSNotification*) notification;
/**
 * Invokes a URL request with the provided information
 * @param url       The url of this request
 * @param callback  The callback of this request on success
 * @param cacheID   The cache identifier of the request (nil for none)
 */
-(void) internalRequestWithURL:(NSURL *)url successCallback:(SEL)callback cacheID:(id) cacheID;
/**
 * Invokes a URL request with the provided information
 * @param userInfo  NSDictionary containing the request elements, specificially
 *                  url and success callback
 */
-(void) internalRequest:(NSDictionary*) userInfo;
/**
 * Stops watching the request for the static class array activeRequests
 * @param req The request to watch
 */
+(void) stopWatchingRequest:(TLURLRequest*) req;
/**
 * Starts watching the request for the static class array activeRequests
 * @param req The request to watch
 */
+(void) startWatchingRequest:(TLURLRequest*) req;
/**
 * Stops watching the notification provided and its embedded request
 * @param notification  The notification to stop observing
 */
-(void) stopInternalRequestNotificationObservation:(NSNotification*) notification;
#pragma mark - Healthcheck

/**
 * Sends a PTV Healthcheck Request to confirm backend health.
 * This should always be run on any new TLPTVRequest
 * @param url       The url to call if healthcheck is OK
 * @param selector  The selector to be invoked for the callback of the url request
 * @param cacheID   The identifier to cache this request under
 */
-(void) requestHealthcheckAndIfOKRequestURL:(NSURL*) url
                               withCallback:(SEL) callback
                                    cacheID:(id) cacheID;
/**
 * Validates the PTV healthcheck data returned. Will fail the PTV request if
 * data could not be validated, otherwise it will invoke the _requestInvocation
 * if everything was OK and the *actual* request should go ahead
 * @param notification  The invoking notification
 */
-(void) callbackHealthcheckValidationWithNofitication:(NSNotification*) notification;

#pragma mark - Search for station request definitions

/**
 * Sends a PTV Search request for stations with the given name
 * @param userInfo  Information to pass to this request
 */
-(void) requestSearchForStationWithSearchString:(NSDictionary *)userInfo;
/**
 * Callback for search for station with data
 * @param notification  The invoking notification
 */
-(void) callbackSearchForStationWithNotification:(NSNotification*) notification;
/**
 * Parses the response data from search station requests for the data needed
 * @param data  The raw response data to parse
 * @return      The search station data needed
 */
-(NSArray*) parseSearchStationResponseData:(NSArray*) data;

#pragma mark - Broad Next Departures requests

/**
 * Sends a PTV Search request for the next departures for the given stop
 * @param userInfo  Information to pass to this request
 */
-(void) requestBroadNextDeparturesForStation:(NSDictionary*) userInfo;
/**
 * Callback for search for broad next departures with data
 * @param notification  The invoking notification
 */
-(void) callbackRequestBroadNextDeparturesWithNotification:(NSNotification*) notification;
/**
 * Parses the response data from broad next depts requests for the data needed
 * @param data  The raw response data to parse
 * @return      The broad next departures data needed
 */
-(NSArray*) parseBroadNextDeparturesData:(NSArray*) data;

#pragma mark - Line Departures

/**
 * Sends a PTV Search request for the lines on a given stop
 * @param userInfo  Information to pass to this request
 */
-(void) requestLinesDepartingForStation:(NSDictionary*) userInfo;
/**
 * Callback for search for broad next departures with data
 * @param notification  The invoking notification
 */
-(void) callbackRequestLinesDepartingForStation:(NSNotification*) notification;
/**
 * Parses the response data from broad next depts requests for the data needed
 * @param data  The raw response data to parse
 * @return      The broad next departures data needed
 */
-(NSArray*) parseLinesDepartureData:(NSArray*) data;

@end

@implementation TLPTVRequest

#pragma mark - Property Synthesis

-(float) percentageLoaded
{
  // Internal request given not healthcheck
  if (_internalRequest && !_performingHealthcheck)
    return [_internalRequest percentageLoaded];
  else
    return 0.0f;
}

#pragma mark - Convenience Constructors for Requests

+(id) requestStationSearch:(NSString *)query
                successSel:(SEL)successSelector
                failureSel:(SEL)failureSelector
                    sender:(id)sender
{
  // Setup keyword and selector
  NSString* const REQUEST_KEY = @"requestStationSearch";
  SEL       const REQUEST_SEL = @selector(requestSearchForStationWithSearchString:);
  
  // Return new request based on this request
  return [self requestWithRequestKey:REQUEST_KEY
                     requestSelector:REQUEST_SEL
                     requestUserInfo:@{@"query":query}
                     successSelector:successSelector
                     failureSelector:failureSelector
                              sender:sender];
}
+(id) requestBroadNextDeparturesForStopID:(NSNumber *)stopID
                            toDirectionID:(NSNumber*) dirID
                                  showAll:(BOOL) showAll
                               successSel:(SEL) successSelector
                               failureSel:(SEL) failureSelector
                                   sender:(id) sender;
{
  // Setup keyword and selector
  NSString* const REQUEST_KEY = @"requestBroadNextDepartures";
  SEL       const REQUEST_SEL = @selector(requestBroadNextDeparturesForStation:);
  
  // Return new request based on this request
  return [self requestWithRequestKey:REQUEST_KEY
                     requestSelector:REQUEST_SEL
                     requestUserInfo: @{
                                          @"stopID":stopID,
                                          @"showAll": [NSNumber numberWithBool:showAll],
                                          @"reqParams": @{@"dirID": dirID}
                                       }
                     successSelector:successSelector
                     failureSelector:failureSelector
                              sender:sender];
}
+(id) requestLinesForStopID:(NSNumber *)stopID
                 successSel:(SEL)successSelector
                 failureSel:(SEL)failureSelector
                     sender:(id)sender
{
  // Setup keyword and selector
  NSString* const REQUEST_KEY = @"requestLines";
  SEL       const REQUEST_SEL = @selector(requestLinesDepartingForStation:);
  
  // Return new request based on this request
  return [self requestWithRequestKey:REQUEST_KEY
                     requestSelector:REQUEST_SEL
                     requestUserInfo: @{
                                        @"stopID":stopID
                                       }
                     successSelector:successSelector
                     failureSelector:failureSelector
                              sender:sender];
}


#pragma mark - Initalisers

// Class initialiser to initialise static array
+ (void)initialize
{
  if (self == [TLPTVRequest class])
  {
    activeRequests = [[NSMutableArray alloc] init];
  }
}

+(id) requestWithRequestKey:(NSString*) requestKey
            requestSelector:(SEL) requestSelector
            requestUserInfo:(NSDictionary*) requestUserInfo
            successSelector:(SEL) successSelector
            failureSelector:(SEL) failureSelector
                     sender:(id) sender
{
  // Setup NSNotification observation for this request on the sender
  [self setupNotificationObservationForKeyword:requestKey
                               successSelector:successSelector
                               failureSelector:failureSelector
                                      observer:sender];
  
  // Setup the request and perform the request on it
  TLPTVRequest* retVal = [[TLPTVRequest alloc] initWithRequestKeyword:requestKey
                                                      requestSelector:requestSelector
                                                      requestUserInfo:requestUserInfo];
  // Start the request in background thread
  [retVal performSelectorInBackground:requestSelector
                           withObject:requestUserInfo];
  // Return the new request
  return retVal;
}

-(id) initWithRequestKeyword:(NSString*) requestKeyword
             requestSelector:(SEL) requestSelector
             requestUserInfo:(NSDictionary*) requestUserInfo
{
  if (self = [super init])
  {
    _requestKeyword     = requestKeyword;
    _requestSelector    = requestSelector;
    _requestUserInfo    = requestUserInfo;
    _requestParseParams = _requestUserInfo[@"reqParams"];
    _internalRequest    = nil;
    _performingHealthcheck  = YES;
  }
  return self;
}

#pragma mark - Helpers

+(void) setupNotificationObservationForKeyword:(NSString*) requestKeyword
                               successSelector:(SEL) successSelector
                               failureSelector:(SEL) failureSelector
                                      observer:(id) observer
{
  // Setup success selector to be called on success
  [[NSNotificationCenter defaultCenter] addObserver:observer
                                           selector:successSelector
                                               name:[NSString stringWithFormat:@"%@SUCCESS", requestKeyword]
                                             object:nil];
  // Setup failure selector to be called on failure
  [[NSNotificationCenter defaultCenter] addObserver:observer
                                           selector:failureSelector
                                               name:[NSString stringWithFormat:@"%@FAILURE", requestKeyword]
                                             object:nil];
}

#pragma mark - Requests Manipulation

+(void) flushRequests
{
  // Cancel all requests
  for (TLURLRequest* c in activeRequests)
    [c cancel];

  // Flush the active requests array
  [activeRequests removeAllObjects];
}

+(void) stopWatchingRequest:(TLURLRequest*) req
{
  // Given request isn't nil (i.e., cached)
  if (req)
  {
    [req cancel];
    [activeRequests removeObject:req];
  }
}

+(void) startWatchingRequest:(TLURLRequest*) req
{
  // Given request isn't nil (i.e., cached)
  if (req)
    [activeRequests addObject:req];
}

#pragma mark - Failure and Success notifications

-(void) postSuccessNotificationWithData:(id)data
{
  NSString* notifName = [NSString stringWithFormat:@"%@SUCCESS", _requestKeyword];
  [[NSNotificationCenter defaultCenter] postNotificationName:notifName
                                                      object:self
                                                    userInfo:@{@"data" : data} ];
}
-(void) postFailureNotificationWithError:(id)error
{
  // Stop watching this request
  NSString* notifName = [NSString stringWithFormat:@"%@FAILURE", _requestKeyword];
  [[NSNotificationCenter defaultCenter] postNotificationName:notifName
                                                      object:self
                                                    userInfo:@{@"data"   : error,
                                                               @"request": self} ];
}
-(void) internalRequestWithURL:(NSURL *)url successCallback:(SEL)callback cacheID:(id) cacheID;
{
  // Setup new request
  if (cacheID != [NSNull null])
    _internalRequest = [TLURLRequest cachedRequestWithIdentifier:cacheID
                                                  requestWithURL:url
                                                 successSelector:callback
                                                 failureSelector:@selector(internalRequestFailureCallback:)
                                                          sender:self];
  else
    _internalRequest = [TLURLRequest requestWithURL:url
                                    successSelector:callback
                                    failureSelector:@selector(internalRequestFailureCallback:)
                                             sender:self];
  
  // New request to start watching
  [TLPTVRequest startWatchingRequest:_internalRequest];
}
-(void) internalRequest:(NSDictionary *)userInfo
{
  [self internalRequestWithURL:[userInfo objectForKey:@"url"]
               successCallback:NSSelectorFromString([userInfo objectForKey:@"callbackName"])
                       cacheID:[userInfo objectForKey:@"cacheID"]];
}
-(void) internalRequestFailureCallback:(NSNotification*) notification
{
  // Need to stop watching the request (i.e., sender of internal failure)
  [self stopInternalRequestNotificationObservation:notification];
  
  // Post failure notification with error data
  [self postFailureNotificationWithError:[notification userInfo][@"data"]];
}
-(void) stopInternalRequestNotificationObservation:(NSNotification *)notification
{
  // Stop watching this request (the object of this notification is the TLURLRequest)
  [TLPTVRequest stopWatchingRequest:[notification object]];
  // Remove self from internal request observation (no longer need to observe)
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:[notification name]
                                                object:nil];
}
#pragma mark - Healthcheck Requests

-(void) requestHealthcheckAndIfOKRequestURL:(NSURL*) url
                               withCallback:(SEL) callback
                                    cacheID:(id)cacheID
{
  // Switch the new request selector not to me (else endless loop)
  // but to my invoker
  _requestSelector = @selector(internalRequest:);
  
  // Need to wrap up the selector in an NSString for it to be passed as an object
  _requestUserInfo = @{
                        @"url" : url,
                        @"callbackName" : NSStringFromSelector(callback),
                        @"cacheID" : cacheID
                     };
  
  // Starting healthcheck...
  _performingHealthcheck = YES;
  // Append datetime in standard UTF8 Format
  NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
  NSString* now = [dateFormatter stringFromDate:[NSDate date]];
  
  // Get the URL
  NSURL* reqURL = [TLPTVURLGenerator generateAPIRequestWithBaseUrl:@"/v2/healthcheck"
                                                         andParams:@{@"timestamp": now}];
  // Start watching this request
  SEL const HEALTHCHECK_CALLBACK = @selector(callbackHealthcheckValidationWithNofitication:);
  [TLPTVRequest startWatchingRequest:[TLURLRequest requestWithURL:reqURL
               successSelector:HEALTHCHECK_CALLBACK
               failureSelector:@selector(internalRequestFailureCallback:)
                        sender:self]];
}
-(void) callbackHealthcheckValidationWithNofitication:(NSNotification *)notification
{
  _performingHealthcheck = NO;
  // Stop observing this notification
  [self stopInternalRequestNotificationObservation:notification];
  
  // Get the data out of the notification
  NSDictionary* data = [notification userInfo][@"data"];
  
  // Run healthcheck status...
  BOOL securityTokenOK  = [data[@"securityTokenOK"] boolValue];
  // PTV is ALWAYS returning NO... force YES
  BOOL clientClockOK    = YES; //[data[@"clientClockOK"]   boolValue];
                               // PTV MemCache error is not significicant enough to bring down the app...
  BOOL memcacheOK       = YES; //[data[@"memcacheOK"]      boolValue];
  BOOL databaseOK       = [data[@"databaseOK"]      boolValue];
  BOOL healthcheckOK    = securityTokenOK && clientClockOK && memcacheOK && databaseOK;
  
  NSString* errorMessage = nil;
  
  // Make the user aware of these errors
  if (!securityTokenOK) errorMessage = @"Trainly can't talk with PTV. Please let us know!";
  if (!clientClockOK)   errorMessage = @"Your clock isn't synchronised with PTV.";
  if (!memcacheOK)      errorMessage = @" PTV's database is running slowly.";
  if (!databaseOK)      errorMessage = @" PTV's database is down. Try again later.";
  
  // Healthcheck is not good?
  if (!healthcheckOK)
  {
    NSDictionary* data =  @{
                              @"securityTokenOK":  [NSNumber numberWithBool:securityTokenOK],
                              @"clientClockOK":    [NSNumber numberWithBool:clientClockOK],
                              @"memcacheOK":       [NSNumber numberWithBool:memcacheOK],
                              @"databaseOK":       [NSNumber numberWithBool:databaseOK]
                          };
    
    
    // Pass into the error what's not OK with the request
    NSError* e = [NSError errorWithDomain:NSPOSIXErrorDomain
                                     code:0
                                 userInfo:  @{
                                              @"TLHealthcheckStatus"    : @NO,
                                              @"TLHealthcheckData"      : data,
                                              @"NSLocalizedDescription" : errorMessage
                                              }];
    
    // Fail notification
    [self postFailureNotificationWithError:e];
  }
  // Othewise, all good
  else
  {
    // Invoke the ACTUAL request now...
    [self performSelectorInBackground:_requestSelector
                           withObject:_requestUserInfo];
  }

}

#pragma mark - Search Station Request

-(void) requestSearchForStationWithSearchString:(NSDictionary *)userInfo
{
  NSString* query = userInfo[@"query"];
  
  // Ensure we encode the search string
  query = [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  
  // Get the URL
  NSString* const BASE_URL = [NSString stringWithFormat:@"/v2/search/%@", query];
  // See if we can grab a cached request, otherwise we'll need to perform a healthcheck
  if ([TLURLRequest isCached:BASE_URL])
  {
    // Grabbed cached data
    id data = [TLURLRequest cachedDataWithIdentifier:BASE_URL];
    // Post success with this data
    [self postSuccessNotificationWithData:[self parseSearchStationResponseData:data]];
  }
  // Otherwise, we'll need to push a new request to the
  // PTV Servers, which means a healthcheck
  else
  {
    // Generate request url from base url
    NSURL* const REQ_URL = [TLPTVURLGenerator generateAPIRequestWithBaseUrl:BASE_URL
                                                           andParams:nil];
    SEL const CALLBACK = @selector(callbackSearchForStationWithNotification:);
    [self requestHealthcheckAndIfOKRequestURL:REQ_URL withCallback:CALLBACK cacheID:BASE_URL];
  }
}
-(void) callbackSearchForStationWithNotification:(NSNotification*) notification
{
  // Scoop the data out of the notification
  NSArray* data = [notification userInfo][@"data"];
  
  // 1 - Stop observing this notification
  [self stopInternalRequestNotificationObservation:notification];
  // 2 - Post success with parsed data
  [self postSuccessNotificationWithData:[self parseSearchStationResponseData:data]];
}
-(NSArray*) parseSearchStationResponseData:(NSArray*) data
{
  // Parse through each of the items in result set; get
  // [@"result"][@"transport_type"] == "train" only!
  // (and remove line_name if the station name is also a line---e.g. Hurstbridge station vs
  // Hurstbridge line (we don't want the line; we only want a stop!!))
  NSPredicate* filterTrainsOnly =
  [NSPredicate predicateWithFormat:
   @"(self.result.transport_type == %@) && (self.type == %@)", @"train", @"stop"];
  NSArray* ptvStations = [data filteredArrayUsingPredicate:filterTrainsOnly];

  // Make ptvStations results compliant with TL and return it
  NSMutableArray* retVal = [[NSMutableArray alloc] init];
  
  // Convert PTV NSDictionary in TL TrainStation-compliant NSDictionary
  for (NSDictionary* result in ptvStations)
  {
    NSMutableDictionary* station = [[NSMutableDictionary alloc] init];
    
    // Chop off 'Station' from location_name
    NSRange r = [result[@"result"][@"location_name"] rangeOfString:@" Station"];
    NSString* newName = [result[@"result"][@"location_name"] stringByReplacingCharactersInRange:r withString:@""];
    
    // Make it compliant
    [station setObject:newName                              forKey:@"name"];
    [station setObject:result[@"result"][@"stop_id"]        forKey:@"stopID"];
    [station setObject:result[@"result"][@"lat"]            forKey:@"latitude"];
    [station setObject:result[@"result"][@"lon"]            forKey:@"longitude"];
    [station setObject:result[@"result"][@"suburb"]         forKey:@"suburb"];
    
    // Add it to the retVal
    [retVal addObject:station];
  }
  
  return retVal;
}

#pragma mark - Broad Next Departures

-(void) requestBroadNextDeparturesForStation:(NSDictionary *)userInfo
{
  NSInteger stopID = [userInfo[@"stopID"] integerValue];
  BOOL allDay = [userInfo[@"showAll"] boolValue];
  
  // Get the URL
  NSString* const BASE_URL = [NSString stringWithFormat:
                              @"/v2/mode/%d/stop/%d/departures/by-destination/",
                              0,             // 0 for train mode only
                              stopID];       // departing stop number
  // See if we can grab a cached request, otherwise we'll need to perform a healthcheck
  if ([TLURLRequest isCached:BASE_URL])
  {
    // Grabbed cached data
    id data = [TLURLRequest cachedDataWithIdentifier:BASE_URL];
    // Post success with this data
    [self postSuccessNotificationWithData:[self parseBroadNextDeparturesData:data]];
  }
  // Otherwise, we'll need to push a new request to the
  // PTV Servers, which means a healthcheck
  else
  {
    // next 5 stops (not all day) or 0 for all day
    NSString* nextXStopsURL = [NSString stringWithFormat:@"%@limit/%d", BASE_URL, allDay ? 0:5];
    // Generate request url from base url
    NSURL* const REQ_URL = [TLPTVURLGenerator generateAPIRequestWithBaseUrl:nextXStopsURL
                                                                  andParams:nil];
    SEL const CALLBACK = @selector(callbackRequestBroadNextDeparturesWithNotification:);
    [self requestHealthcheckAndIfOKRequestURL:REQ_URL withCallback:CALLBACK cacheID:BASE_URL];
  }
}
-(void) callbackRequestBroadNextDeparturesWithNotification:(NSNotification *)notification
{
  // Scoop the data out of the notification
  NSArray* data = [notification userInfo][@"data"];
  
  // 1 - Stop observing this notification
  [self stopInternalRequestNotificationObservation:notification];
  // 2 - Post success with parsed data
  [self postSuccessNotificationWithData:[self parseBroadNextDeparturesData:data]];
}
-(NSArray*) parseBroadNextDeparturesData:(NSDictionary *)data
{
  NSMutableArray* retVal = [[NSMutableArray alloc] init];
  NSNumber* directionToFilter = _requestParseParams[@"dirID"];

  // Parser for dates
  NSDateFormatter* isoToDate = [[NSDateFormatter alloc] init];
  [isoToDate setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
  
  // Scan through each value result in value array from json results (where no
  // results, will iterate and skip)
  for (NSDictionary* run in data[@"values"])
  {
    // Given this was a station in the direction we wanted?
    if (run[@"platform"][@"direction"][@"direction_id"] == directionToFilter)
    {
      NSDate* date = [isoToDate dateFromString:run[@"time_timetable_utc"]];
      BOOL isExpress = [run[@"run"][@"num_skipped"] integerValue] > 0;
      NSLog(@"isExpress=%hhd", isExpress);
      NSDictionary* retRun = @{
                                @"departureTime": date,
                                @"expressStatus": isExpress ?
                                @"Limited Express" : @"All Stations"
                               };
  
  
      [retVal addObject:retRun];
    }
  }
  
  return retVal;
}

#pragma mark - Lines Departing

-(void) requestLinesDepartingForStation:(NSDictionary *)userInfo
{
  NSInteger stopID = [userInfo[@"stopID"] integerValue];
  
  // Get the URL
  NSString* const BASE_URL = [NSString stringWithFormat:
                              @"/v2/mode/%d/stop/%d/departures/by-destination/",
                              0,             // 0 for train mode only
                              stopID];       // departing stop number
  if ([TLURLRequest isCached:BASE_URL])
  {
    // Grabbed cached data
    id data = [TLURLRequest cachedDataWithIdentifier:BASE_URL];
    // Post success with this data
    [self postSuccessNotificationWithData:[self parseLinesDepartureData:data]];
  }
  // Otherwise, we'll need to push a new request to the
  // PTV Servers, which means a healthcheck
  else
  {
    NSString* allDayBaseURL = [NSString stringWithFormat:@"%@limit/0", BASE_URL];
    // Generate request url from base url
    NSURL* const REQ_URL = [TLPTVURLGenerator generateAPIRequestWithBaseUrl:allDayBaseURL
                                                                  andParams:nil];
    SEL const CALLBACK = @selector(callbackRequestLinesDepartingForStation:);
    [self requestHealthcheckAndIfOKRequestURL:REQ_URL withCallback:CALLBACK cacheID:BASE_URL];
  }
}
-(void) callbackRequestLinesDepartingForStation:(NSNotification *)notification
{
  // Scoop the data out of the notification
  NSArray* data = [notification userInfo][@"data"];
  
  // 1 - Stop observing this notification
  [self stopInternalRequestNotificationObservation:notification];
  // 2 - Post success with parsed data
  [self postSuccessNotificationWithData:[self parseLinesDepartureData:data]];
}
-(NSArray*) parseLinesDepartureData:(NSDictionary *)data
{
  NSMutableArray* retVal = [[NSMutableArray alloc] init];
  
  // Scan through each value result in value array from json results (where no
  // results, will iterate and skip)
  for (NSDictionary* result in data[@"values"])
  {
    NSDictionary* direction = result[@"platform"][@"direction"];
    NSNumber* directionID = [NSNumber numberWithInteger:[direction[@"direction_id"] integerValue]];
    NSPredicate* alreadyIncludedDirections
    = [NSPredicate predicateWithFormat:@"direction_id == %@", directionID];
    // If the retVal doesn't have a direction with this id?
    if ([[retVal filteredArrayUsingPredicate:alreadyIncludedDirections] count] == 0)
    {
      // Add it!
      [retVal addObject:direction];
    }
  }
  
  return retVal;
}

@end
