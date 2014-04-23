//
//  TLTrainStation.h
//  Trainly
//
//  Created by Alex on 5/04/2014.
//  Copyright (c) 2014 Alex Cummaudo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <MapKit/MapKit.h>

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

@end
