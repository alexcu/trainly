#import "TLViewUsesStationData.h"
#import "TLTrainStation.h"
#import "TLAppDelegate.h"

@implementation TLViewUsesStationData

#pragma mark - Setup

-(void) provideViewWithStationData:(id)stationData
{
  // This method will convert a provided TLTrainStation object into a NSDictionary
  // with assorted key value pairs
  if ([stationData isKindOfClass:[TLTrainStation class]])
  {
    _trainStationData = stationData;
  }
  // Likewise, it will validate a provided NSDictionary for TLTrainStation required items
  else if ([stationData isKindOfClass:[NSDictionary class]])
  {
    // Validate the data provided in the NSDictionary
    if ([[stationData objectForKey:@"latitude"      ] isKindOfClass:[NSNumber class]] &&
        [[stationData objectForKey:@"longitude"     ] isKindOfClass:[NSNumber class]] &&
        [[stationData objectForKey:@"stopID"        ] isKindOfClass:[NSNumber class]] &&
        [[stationData objectForKey:@"name"          ] isKindOfClass:[NSString class]] &&
        [[stationData objectForKey:@"suburb"        ] isKindOfClass:[NSString class]])
    {
      NSManagedObjectContext* moc = [(TLAppDelegate*)[[UIApplication sharedApplication] delegate] moc];
      _trainStationData = [[TLTrainStation alloc] initWithEntity:[NSEntityDescription entityForName:@"TrainStation"
                                                                             inManagedObjectContext:moc]
                                  insertIntoManagedObjectContext:moc];
      
      [_trainStationData setValuesForKeysWithDictionary:stationData];
    }
  }
  // This is a station name only?
  else if ([stationData isKindOfClass:[NSString class]])
  {
    // We can set the station name... BUT
    _trainStationName = stationData;
    return;
  }
}

#pragma mark - Validation

- (BOOL) isAStationInMelbourne:(NSString*) name
{
  // Confirm that this station exists in the list of Melbourne stations...
  TLAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
  NSURL* stationsPath = [appDelegate readMainBundleResourceWithName:@"melbourne_stations_list"
                         
                                                             ofType:@"txt"];
  NSArray* stations = [[NSString stringWithContentsOfURL:stationsPath
                                                encoding:NSUTF8StringEncoding error:nil]
                       componentsSeparatedByString:@"\n"];
  NSArray* results = [stations filteredArrayUsingPredicate:
                      [NSPredicate predicateWithFormat:
                       @"self = %@", name]];
  // There must be only one station with this name!
  return [results count] == 1;
}

- (BOOL) isValidStationData:(NSDictionary *)data
{
  // Confirm keys required and their respective types
  if ([[data objectForKey:@"latitude"      ] isKindOfClass:[NSNumber class]] &&
      [[data objectForKey:@"longitude"     ] isKindOfClass:[NSNumber class]] &&
      [[data objectForKey:@"stopID"        ] isKindOfClass:[NSNumber class]] &&
      [[data objectForKey:@"name"          ] isKindOfClass:[NSString class]] &&
      [[data objectForKey:@"suburb"        ] isKindOfClass:[NSString class]])
  {
    // Now confirm the name
    return [self isAStationInMelbourne:[data objectForKey:@"name"]];
  }
  // Invalid data!
  else
    return NO;
}

@end
