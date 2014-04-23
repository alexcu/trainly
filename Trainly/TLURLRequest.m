#import "TLURLRequest.h"

/// The cache bank stores requests that have already been fetched
static NSCache* cacheBank;
/// The timeout in seconds
const static NSTimeInterval TIMEOUT_SECONDS = 3.5;

@interface TLURLRequest()
/**
 * Initialises a new network request
 * @param identifier          Cache identifier
 * @param url                 The url for the request
 * @param successSelector     The succcess Selector to invoke on success
 * @param failureSelector     The failure Selector to invoke on failure or timeout
 * @param sender              The sender of this request
 */
-(id) initCachedRequestWithIdentifier:(NSString*) identifier
                       requestWithURL:(NSURL *)url
                      successSelector:(SEL) successSelector
                      failureSelector:(SEL) failureSelector
                               sender:(id) sender;
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
@end

@implementation TLURLRequest

#pragma mark - Property Synthesis

-(float) percentageLoaded
{
  // Data must have been recieved!
  if (_recievedData && _expectedContentLength)
  {
    // Give the expected header length
    if (_expectedContentLength != NSURLResponseUnknownLength)
      return (float)[_recievedData length] / _expectedContentLength;
    else
      return 1.0f;
  }
  else
    return 0.0f;
}

#pragma mark - Setup

+ (void)initialize
{
  if (self == [TLURLRequest class])
  {
    cacheBank = [[NSCache alloc] init];
  }
}

+(id) cachedRequestWithIdentifier:(NSString*) identifier
                   requestWithURL:(NSURL *)url
                  successSelector:(SEL) successSelector
                  failureSelector:(SEL) failureSelector
                           sender:(id) sender
{
  TLURLRequest* retVal =  [[TLURLRequest alloc] initCachedRequestWithIdentifier:identifier
                                                                 requestWithURL:url
                                                                successSelector:successSelector
                                                                failureSelector:failureSelector
                                                                         sender:sender];
  // Start the request
  [retVal performSelectorOnMainThread:@selector(startRequest)
                           withObject:nil waitUntilDone:NO];
  
  return retVal;
}
+(id) requestWithURL:(NSURL*) url
     successSelector:(SEL) successSelector
     failureSelector:(SEL) failureSelector
              sender:(id) sender
{
  TLURLRequest* retVal =  [[TLURLRequest alloc] initCachedRequestWithIdentifier:nil
                                                                 requestWithURL:url
                                                                successSelector:successSelector
                                                                failureSelector:failureSelector
                                                                         sender:sender];
  // Start the request
  [retVal performSelectorOnMainThread:@selector(startRequest)
                           withObject:nil waitUntilDone:NO];
  
  return retVal;
}
-(id) initCachedRequestWithIdentifier:(NSString*) identifier
                       requestWithURL:(NSURL *)url
                      successSelector:(SEL) successSelector
                      failureSelector:(SEL) failureSelector
                               sender:(id) sender
{
  if (self = [super init])
  {
    // Setup observation on sender for failure and successs
    // (using urlSUCCESS/urlFAILURE as name)
    [[NSNotificationCenter defaultCenter] addObserver:sender
                                             selector:successSelector
                                                 name:[NSString stringWithFormat:@"%@SUCCESS", url]
                                               object:self];
    [[NSNotificationCenter defaultCenter] addObserver:sender
                                             selector:failureSelector
                                                 name:[NSString stringWithFormat:@"%@FAILURE", url]
                                               object:self];
    _url = url;
    _sender = sender;
    _recievedData = [[NSMutableData alloc] init];
    _cacheIdentifier = identifier;
    _expectedContentLength = 0;
    if (_cacheIdentifier)
      _shouldCacheResponse = YES;
    else
      _shouldCacheResponse = NO;
    // Start the request
    NSLog(@"SENDING REQUEST (%@) [Cached:%hhd]->%@", self, _shouldCacheResponse, url);
  }
  return self;
}

-(void) dealloc
{
  NSLog(@"DEALLOC (%@) %@", self, _ctn);
}

-(void) startRequest
{
  // If the cache bank already has a request cached with the given identifier?
  if ([TLURLRequest isCached:_cacheIdentifier])
  {
    // Invoke success with cached data
    id data = [cacheBank objectForKey:_cacheIdentifier];
    [self postSuccessNotificationWithData:data];
  }
  else
  {
    // Setup a new connection
    NSURLRequest* req = [NSURLRequest requestWithURL:_url
                                         cachePolicy:NSURLCacheStorageAllowedInMemoryOnly
                                     timeoutInterval:TIMEOUT_SECONDS];
    _ctn = [NSURLConnection connectionWithRequest:req
                                         delegate:self];
  }
}

#pragma mark - Caching

+(id) cachedDataWithIdentifier:(NSString *)identifier
{
  return [cacheBank objectForKey:identifier];
}

+(BOOL) isCached:(NSString *)identifier
{
  return [cacheBank objectForKey:identifier] != nil;
}

#pragma mark - NSURLConnectionDataDelegate Methods

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
  // Clear data each time we reconnect
  [_recievedData setLength:0];
  // Now we know how long the request will be
  _expectedContentLength = [response expectedContentLength];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
  // Finished loading all the data? Then parse the json
  // and finally fire the _successSelector....
  
  // Decode JSON (all TLURLRequests are responded back from PTV in JSON)
  NSError* jsonParseError = nil;
  NSDictionary* json = [NSJSONSerialization JSONObjectWithData:_recievedData
                                                       options:NSJSONReadingAllowFragments
                                                         error:&jsonParseError];
  // Parsed json
  if (!jsonParseError && json)
  {
    // Store the data for this request under the identifier provided
    if (_shouldCacheResponse)
    {
      [cacheBank setObject:json forKey:_cacheIdentifier];
    }
    // ...successfully? Then invoke success with json
    [self postSuccessNotificationWithData:json];
  }
  else
    // ...failure? Then invoke fail with error
    [self postFailureNotificationWithError:jsonParseError];
}

-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
//  NSLog(@"RECIEVED DATA (%@): %@", self, data);
  // Append to the data
  [_recievedData appendData:data];
}
-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
  // Fail occured
  [self postFailureNotificationWithError:error];
}

-(void) cancel
{
  NSLog(@"WAS CANCELLED (%@)", self);
  // Cancel the connection
  [_ctn cancel];
}

#pragma mark - Failure and Success notifications

-(void) postSuccessNotificationWithData:(id)data
{
  NSString* notifName = [NSString stringWithFormat:@"%@SUCCESS", _url];
  [[NSNotificationCenter defaultCenter] postNotificationName:notifName
                                                      object:self
                                                    userInfo:@{@"data" : data,
                                                               @"url"  : _url,
                                                               @"req"  : self} ];
  NSLog(@"RECIEVED RESPONSE (%@)", self);
}

-(void) postFailureNotificationWithError:(id)error
{
  NSString* notifName = [NSString stringWithFormat:@"%@FAILURE", _url];
  [[NSNotificationCenter defaultCenter] postNotificationName:notifName
                                                      object:self
                                                    userInfo:@{@"data" : error,
                                                               @"url" : _url,
                                                               @"req"  : self} ];
  NSLog(@"FAILED RESPONSE (%@)-> %@",self,  error);
}

@end
