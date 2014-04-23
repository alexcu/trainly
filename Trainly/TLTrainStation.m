//
//  TLTrainStation.m
//  Trainly
//
//  Created by Alex on 5/04/2014.
//  Copyright (c) 2014 Alex Cummaudo. All rights reserved.
//

#import "TLTrainStation.h"


@implementation TLTrainStation

@dynamic latitude;
@dynamic longitude;
@dynamic name;
@dynamic stopID;
@dynamic suburb;
@dynamic isFavourite;

#pragma mark - Property Synthesis

-(CLLocationCoordinate2D) coordinate
{
  return CLLocationCoordinate2DMake([[self latitude] doubleValue],
                                    [[self longitude] doubleValue]);
}

-(NSString*) description
{
  return [self name];
}

@end
