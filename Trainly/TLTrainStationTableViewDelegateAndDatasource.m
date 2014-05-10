#import "TLTrainStationTableViewDelegateAndDatasource.h"
#import "TLTrainStation.h"

/// Limit until the displayed stations should be aggregated into sections
static const NSInteger LIMIT_FOR_SECTIONS = 6;

/// Prototype cell identifier for all TLTrainStationTableViewDelegateAndDatasource cells
static NSString* const PROTOTYPE_CELL_ID = @"PrototypeStationCell";

// To provide `protected' access to superclass's validation for cell identifers
@interface TLTrainStationTableViewDelegateAndDatasource()
/**
 * Generates the station labels from data provided
 * @param  stations  The data input to validate
 * @return Arrays containing the station names, nil if bad input provided.
 */
-(NSArray*) generateStationLabelsFromStation:(NSArray*) stations;
/**
 * Aggregates station names by alphabetical order
 * @return  An array of NSArrays that separates each station label separately
 */
- (NSArray*) aggregatedStationNames;
/**
 * Updates the labels in the table
 */
-(void) updateLabels;
@end

@implementation TLTrainStationTableViewDelegateAndDatasource

#pragma mark - Property Synthesis

@synthesize shouldSplitIntoSections = _shouldSplitIntoSections;
// Override setter
-(void) setShouldSplitIntoSections:(BOOL)shouldSplitIntoSections
{
  if (shouldSplitIntoSections == NO)
  {
    _shouldSplitIntoSections = shouldSplitIntoSections;
    // Unaggregate the sections
    _stationNames = [self generateStationLabelsFromStation:_stations];
  }
}

-(NSIndexSet*) sections
{
  // Return sections if we're splitting or not... only 1 section if not splitting
  if (_shouldSplitIntoSections)
  {
    NSRange range;
    range.length = [_stationNames count];
    range.location = 0;
    return [NSIndexSet indexSetWithIndexesInRange:range];
  }
  else
    return [NSIndexSet indexSetWithIndex: 0];
}

#pragma mark - Setup

- (id) initWithAnArrayOfStations:(NSArray *)stations
                   allowsEditing:(BOOL)editing
{
  if (self = [super init])
  {
    _stations = stations;
    _allowsEditing = editing;
    [self updateLabels];
    if (!_stationNames)
      return nil;
  }
  return self;
}
-(NSArray*) generateStationLabelsFromStation:(NSArray*) stations
{
  NSMutableArray* retVal = [[NSMutableArray alloc] init];
  for (id s in stations)
  {
    // Providing in a station class OK
    if ([s isKindOfClass:[TLTrainStation class]])
      // Station name added
      [retVal addObject:[s name]];
    // Providing in a label (assuming it's just a station name) OK
    else if ([s isKindOfClass:[NSString class]])
      [retVal addObject:s];
    // Providing something else; bad validation!
    else
      return nil;
  }
  // Return sorted array
  return [retVal sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

#pragma mark - Helper Methods

- (NSArray*) aggregatedStationNames
{
  NSMutableDictionary* aggregation = [[NSMutableDictionary alloc] init];
  for (NSString* stationName in _stationNames)
  {
    // Prefix letter
    NSString* prefix = [stationName substringToIndex:1];
    // If a key does not yet exist in the aggregation for that prefix?
    if (!([aggregation objectForKey:prefix]))
    {
      // Add a new key with an array of names under that prefix
      [aggregation setObject:[NSMutableArray arrayWithObject:stationName] forKey:prefix];
    }
    else
    {
      // Just add this station name under that prefix
      NSMutableArray* section = [aggregation objectForKey:prefix];
      [section addObject:stationName];
      
      // Sort the section now
      [section sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
      
      // Update the section for this new stationName
      [aggregation setObject:section forKey:prefix];
    }
  }
  
  // Sort the aggregation
  NSArray *aggregationKeysSorted = [[aggregation allKeys] sortedArrayUsingSelector: @selector(localizedCaseInsensitiveCompare:)];
  NSMutableArray *retVal = [NSMutableArray array];
  for (NSString *key in aggregationKeysSorted)
    [retVal addObject: [aggregation objectForKey: key]];
  
  return retVal;
}

-(void) updateData:(NSArray *)data
{
  _stations = data;
  [self updateLabels];
}

-(void) updateLabels
{
  _stationNames = [self generateStationLabelsFromStation:_stations];
  if ([_stations count] > LIMIT_FOR_SECTIONS)
  {
    _stationNames = [self aggregatedStationNames];
    _shouldSplitIntoSections = YES;
  }
  else
    _shouldSplitIntoSections = NO;
}

#pragma mark - Table Datasource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
  // If splitting into sections
  if (_shouldSplitIntoSections)
    return [_stationNames count];
  // Otherwise, one section only
  return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  // Return the relative number of rows depending on section
  if (_shouldSplitIntoSections)
    return [[_stationNames objectAtIndex:section] count];
  // Or return the overall count if not splitting
  else
    return [_stations count];
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  // Flyweight dequeue if avaliable
  UITableViewCell* c = [tableView dequeueReusableCellWithIdentifier:PROTOTYPE_CELL_ID];
  
  // Allocate one if none avaliable
  if (!c)
    c = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                               reuseIdentifier:PROTOTYPE_CELL_ID];
  
  NSString* labelText = [self stationNameFromIndexPath:indexPath];
  
  // Set title of c
  [[c textLabel] setText:labelText];
  [c setAccessoryView:nil];
  
  return c;
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  // Return nil if we want no splitting
  if (!_shouldSplitIntoSections)
    return nil;
  else
    // Get this section's first item's prefix
    return [[[_stationNames objectAtIndex:section] objectAtIndex:0] substringToIndex:1];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
  // Return nil if we want no splitting
  if (!_shouldSplitIntoSections)
    return nil;
  else
  {
    NSMutableArray* retVal = [[NSMutableArray alloc] init];
    // Return an array of all the first characters of each station that I have
    for (id section in _stationNames)
    {
      [retVal addObject:[[section objectAtIndex:0] substringToIndex:1]];
    }
    return retVal;
  }
}

-(BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
  return _allowsEditing;
}

-(void) tableView:(UITableView*) tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
  // Delete?
  if (editingStyle == UITableViewCellEditingStyleDelete)
  {
    // Find the station from row at index path and push kill favourite request
    TLTrainStation* stationToKill = [self stationFromIndexPath:indexPath];
    // Push kill notification
    [[NSNotificationCenter defaultCenter] postNotificationName:@"killFavourite"
                                                        object:self
                                                      userInfo:@{@"station": stationToKill,
                                                                 @"indexPath": indexPath}];
  }
}

#pragma mark - Table Delegate

- (id) anyStationDataFromIndexPath:(NSIndexPath*) indexPath
{
  TLTrainStation* actualStation = [self stationFromIndexPath:indexPath];
  // Got an actual station
  if (actualStation)
    return actualStation;
  // Otherwise just grab the name
  else
    return [self stationNameFromIndexPath:indexPath];
}

- (NSString*) stationNameFromIndexPath:(NSIndexPath *)indexPath
{
  // Get corresponding indexPath from _stationNames
  if (_shouldSplitIntoSections)
    return [[_stationNames objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
  else
    return [_stationNames objectAtIndex:indexPath.row];
}

- (TLTrainStation*) stationFromIndexPath:(NSIndexPath *)indexPath
{
  TLTrainStation* retVal;
  // Get corresponding indexPath from _stationNames
  if (_shouldSplitIntoSections)
  {
    // Start at the row of this section
    NSInteger indexOfStation = [indexPath row];
    // Aggrgate the other sections
    for (NSInteger i = 0; i < [indexPath section]; i++)
      indexOfStation += [[_stationNames objectAtIndex:i] count];
    {
      retVal = [_stations objectAtIndex:indexOfStation];
    }
  }
  else
    retVal = [_stations objectAtIndex:indexPath.row];
  // Ensure we're returning a TLTrainStation
  if ([retVal isKindOfClass:[TLTrainStation class]])
  {
    return retVal;
  }
  else
  {
    // Else this isn't a TLTrainStation; return nil!
    return nil;
  }
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForStationWithName:(NSString*) name;
{
  // Get corresponding indexPath from _stationNames
  if (_shouldSplitIntoSections)
  {
    // Get the first letter of the station for section
    NSArray* matchingSectionArray =
      [_stationNames filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self contains %@", name]];
    NSInteger section = [_stationNames indexOfObject:matchingSectionArray];
    NSInteger row = [matchingSectionArray indexOfObject:name];
    return [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
  }
  else
  {
    NSInteger row = [_stationNames indexOfObject:name];
    return [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
  }
}

@end