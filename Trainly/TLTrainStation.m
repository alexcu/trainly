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

-(NSString*) generatePTVOpenURL
{
  return [NSString stringWithFormat:
          @"http://ptv.vic.gov.au/timetables/ModeSearchForm?Mode=2&Search=%@", self.name];
}

-(NSString*) generateMapURL
{
  return [NSString stringWithFormat:
          @"http://maps.apple.com/?ll=%f,%f",
          [self coordinate].latitude, [self coordinate].longitude];
}

@end
