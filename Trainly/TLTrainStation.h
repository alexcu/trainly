#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <MapKit/MapKit.h>

/**
 * Model Train Station Object managed by CoreData
 * @author  Alex Cummaudo
 * @date    2014-04-07
 */
@interface TLTrainStation : NSManagedObject

/// The latitude of this station
@property (nonatomic, retain) NSNumber * latitude;
/// The longitude of this station
@property (nonatomic, retain) NSNumber * longitude;
/// The name of this station
@property (nonatomic, retain) NSString * name;
/// The stop ID of this station
@property (nonatomic, retain) NSNumber * stopID;
/// The suburb of this station
@property (nonatomic, retain) NSString * suburb;
/// Whether or not this station is a favourite
@property BOOL       isFavourite;

/// Coordinates of this station
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

/**
 * Generates map url for the current map displayed
 * @return The map link for the map displayed
 */
-(NSString*) generateMapURL;
/**
 * Generates a link to the PTV site for this station
 * @return The link to this station
 */
-(NSString*) generatePTVOpenURL;

@end
