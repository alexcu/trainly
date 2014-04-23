#import <Foundation/Foundation.h>

/**
 * Wraps all network connection requests with
 * simple ways to use via NSSelectors
 * @author  Alex Cummaudo
 * @date    2014-04-07
 */
@interface TLURLRequest : NSObject
<NSURLConnectionDataDelegate, NSURLConnectionDataDelegate>
{
  /// The url to grab
  NSURL* _url;
  /// The connection
  NSURLConnection* _ctn;
  /// The data I have recieved
  NSMutableData* _recievedData;
  /// The sender---to be retained by me until I'm dealloc'ed
  id _sender;
  /// The cache identifier
  NSString* _cacheIdentifier;
  /// Whether or not this request will be cached
  BOOL _shouldCacheResponse;
  /// Expected content length for this request
  long long _expectedContentLength;
}

/**
 * Convenience constructor for a new network request that's cached into memory
 * @param identifier          Cache identifier
 * @param url                 The url for the request
 * @param successSelector   The succcess Selector to invoke on success
 * @param failureSelector   The failure Selector to invoke on failure or timeout
 * @param sender              The sender of this request
 */
+(id) cachedRequestWithIdentifier:(NSString*) identifier
                   requestWithURL:(NSURL *)url
                  successSelector:(SEL) successSelector
                  failureSelector:(SEL) failureSelector
                           sender:(id) sender;

/**
 * Convenience constructor for a new network request
 * @param url                 The url for the request
 * @param successSelector   The succcess Selector to invoke on success
 * @param failureSelector   The failure Selector to invoke on failure or timeout
 * @param sender              The sender of this request
 */
+(id) requestWithURL:(NSURL*) url
     successSelector:(SEL) successSelector
     failureSelector:(SEL) failureSelector
              sender:(id) sender;

/**
 * Sees if caching has been performed with the given cache identifier
 * @param identifier  The cache identifier
 * @return  True if object exists for cache idenfitier, false otherwise
 */
+(BOOL) isCached:(NSString*) identifier;
/**
 * Grabs data that was cached with this identifier
 * @param   identifier  The cache identifier to grab data under
 * @return  Cached data under this identifier; false if no such data exists
 */
+(id) cachedDataWithIdentifier:(NSString*) identifier;

/**
 * Cancels this request
 */
-(void) cancel;

/// The percentage loaded from this request
@property (readonly) float percentageLoaded;

@end
