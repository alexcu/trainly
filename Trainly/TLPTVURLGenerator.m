// Needed for SHA Key encryption
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import "TLPTVURLGenerator.h"
#import "TLPTVCredentials.h"
@interface TLPTVURLGenerator()
/**
 * Generates a request signature
 * @note The request URL discludes the base URL
 * @param requestURL  The request url, without the base url
 */
+(NSString*) generateDeveloperSuffixForRequestURL:(NSString*) requestURL;
@end


#pragma mark - Developer ID Details

/// Base PTV URL where the API requests should be made
static NSString* const PTV_API_URL      = @"http://timetableapi.ptv.vic.gov.au";
/// PTV API Developer ID Key
static NSString* const PTV_API_DEV_ID   = DEV_ID;
/// PTV API Developer ID Signature
static NSString* const PTV_API_DEV_KEY  = DEV_KEY;

@implementation TLPTVURLGenerator

#pragma mark - Generator Methods

+(NSURL*) generateAPIRequestWithBaseUrl:(NSString*) baseURL
                              andParams:(NSDictionary*) reqParams
{
  // Start the URL string with
  // <PTV_API_URL>/<baseURL>/?devid=<PTV_API_DEV_ID>
  NSMutableString* urlString = [NSMutableString stringWithFormat:@"%@%@?devid=%@",
                                PTV_API_URL, baseURL, PTV_API_DEV_ID];
  
  // Append the query string (&<paramKey>=<paramValue>)
  for (id key in reqParams)
    [urlString appendFormat:@"&%@=%@", key,
     // Ensure we encode the key for URI requests!!
     [reqParams[key] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
  
  // Generate signature
  NSString* const SIGNATURE_KEY = [self generateDeveloperSuffixForRequestURL:urlString];
  [urlString appendFormat:@"&signature=%@", SIGNATURE_KEY];
  
  // Return an NSURL that's encoded with spaces
  return [NSURL URLWithString:urlString];
}
+(NSString*) generateDeveloperSuffixForRequestURL:(NSString*) requestURL
{
  // Required for the hash is the full URL -- including base url and request url
  NSMutableString* data = [NSMutableString stringWithString:requestURL];
  
  // Remove the base url
  NSRange baseURLRange = {0,[PTV_API_URL length]};
  [data deleteCharactersInRange:baseURLRange];
  
  /* The following hashing algorithm is provided in the PTV API Documentation */
  
  // Hash the key with the data
  const char* SHA_KEY  = [PTV_API_DEV_KEY cStringUsingEncoding:NSUTF8StringEncoding];
  const char* SHA_DATA = [data cStringUsingEncoding:NSUTF8StringEncoding];
  unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
  CCHmac(kCCHmacAlgSHA1, SHA_KEY, strlen(SHA_KEY), SHA_DATA, strlen(SHA_DATA), cHMAC);
  
  // Work out the output of the key
  NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
  for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
    [output appendFormat:@"%02x", cHMAC[i]];
  NSString* const HASHED_KEY_OUTPUT = [output uppercaseString];
  
  /* End hashing algorithm */
  
  return HASHED_KEY_OUTPUT;
}
@end
