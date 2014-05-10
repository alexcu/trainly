#import "TLGenericTableViewDelegateAndDatasource.h"

@interface TLGenericTableViewDelegateAndDatasource ()
/**
 * Validates data input
 * @return  Returns an NSArray if data was validated, nil otherwise
 */
-(NSArray*) validateDataInputFromDataSource:(NSArray*) src;
/**
 * Validates section cell identifiers
 * @return True if valid, false otherwise
 */
-(BOOL) validateSectionCellIdentifiers:(NSArray*) sectionIDs;
@end

@implementation TLGenericTableViewDelegateAndDatasource

#pragma mark - Public

-(id) initWithSectionData:(NSArray *)data sectionIdentifiers:(NSArray*) sectionIDs;
{
  if (self = [super init])
  {
    NSArray* validatedData = [self validateDataInputFromDataSource:data];
    
    // If validated for data or section IDs did failed?
    if (!validatedData || ![self validateSectionCellIdentifiers:sectionIDs])
      return nil;
    
    // Set ivars after validation
    _sectionData = [[NSArray alloc] initWithArray:validatedData];
    _sectionIDs = sectionIDs;
  }
  return self;
}

-(id) initWithOneSectionData:(NSArray *)data sectionIdentifier:(NSString*) sectionID;
{
  if (self = [super init])
  {
    // Initialise with one section only
    NSMutableArray* oneSection = [[NSMutableArray alloc] initWithObjects:data, nil];
    
    // Validate the data
    NSArray* validatedData = [self validateDataInputFromDataSource:oneSection];
    
    // Data could not be validated?
    if (!validatedData)
      return nil;
    
    // Set ivars after validation
    _sectionData = [[NSArray alloc] initWithArray:oneSection];
    _sectionIDs = [[NSArray alloc] initWithObjects:sectionID, nil];
  }
  return self;
}

#pragma mark - Helper Methods

-(void) tableView:(UITableView *)tableView addActivityIndicatorForCellAtIndexPath:(NSIndexPath *)indexPath
{
  // Get the cell at this index path
  UITableViewCell* selectedCell = [tableView cellForRowAtIndexPath:indexPath];
  
  // Init a new view for spinner view
  UIActivityIndicatorView* spinnerForAccessoryItem =
  [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
  
  // Set color to default blue tint color
  [spinnerForAccessoryItem setColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]];
  [spinnerForAccessoryItem startAnimating];
  
  // Set the accessory view now
  [selectedCell setAccessoryView:spinnerForAccessoryItem];
}

#pragma mark - Input Validation

-(NSArray*) validateDataInputFromDataSource:(NSArray*) src
{
  NSMutableArray* loadData = [[NSMutableArray alloc] init];
  
  // For every datum in this data source
  for (NSArray* d in src)
  {
    // For the elements in this datum)
    for (id e in d)
    {
      // Is this element is acceptable?
      // Only accept NSStrings...
      if ([e isKindOfClass:[NSString class]])
        [loadData addObject:e];
      // ...or NSDictionarys that have string objects set for keys
      // "title" and "subtitle"
      else if ([e isKindOfClass:[NSDictionary class]])
      {
        if ([[e objectForKey:@"title"]    isKindOfClass:[NSString class]] ||
            [[e objectForKey:@"subtitle"] isKindOfClass:[NSString class]])
          [loadData addObject:e];
      }
      // One of the above conditions not met! Failed validation
      else return nil;
    }
  }
  
  return loadData;
}

-(BOOL) validateSectionCellIdentifiers:(NSArray*) sectionIDs
{
  // One ID for each section
  if ([_sectionData count] != [sectionIDs count]) return NO;
  
  // Confirm each sectionID is indeed an NSString
  for (id sID in sectionIDs)
    if (![sID isKindOfClass:[NSString class]]) return NO;
  
  // Validated!
  return YES;
}

#pragma mark - Table Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return [_sectionData count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [[_sectionData objectAtIndex:section] count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  // The label and subtitle to set this label to
  NSString *label, *detailLabel;
  // Gather data for this section
  NSArray* data = [_sectionData objectAtIndex:[indexPath section]];

  // Gather the element infomation (id -- can be an NSString or dictionary)
  id dataElement = [data objectAtIndex:[indexPath row]];
  if ([dataElement isKindOfClass:[NSString class]])
  {
    label = dataElement;
    // No detail label
    detailLabel = nil;
  }
  else if ([dataElement isKindOfClass:[NSDictionary class]])
  {
    label = [dataElement objectForKey:@"title"];
    detailLabel = [dataElement objectForKey:@"subtitle"];
  }
  
  // Gather identifier for this section
  NSString* identifier = [_sectionIDs objectAtIndex:[indexPath section]];
  
  // Get the style for this cell
  UITableViewCellStyle s = UITableViewCellStyleDefault;
  
  // Dequeue first
  UITableViewCell* c = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
  
  // Check if dequeued cell was not avaliable
  if (!c)
    c = [[UITableViewCell alloc] initWithStyle:s reuseIdentifier:identifier];
  
  // Update labels (subtitle too if needed)
  [[c textLabel] setText:label];
  [[c detailTextLabel] setText:detailLabel];
  
  return c;
}

@end
