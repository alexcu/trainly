#import <Foundation/Foundation.h>
/**
 * This class generates request URLs for all Public Transport Victoria requests
 * @author  Alex Cummaudo
 * @date    2014-03-23
 */
@interface TLPTVURLGenerator : NSObject
/**
 * Generates the full request URL needed for the
 * given request type and the URL parameters
 * @param baseURL   The request base url
 * @param reqParams The request type parameters for the API
 * @return          The URL needed for this request to be sent to the server
 */
+(NSURL*) generateAPIRequestWithBaseUrl:(NSString*) baseURL
                              andParams:(NSDictionary*) reqParams;
@end
