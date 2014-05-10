#import "TLSearchForStationViewController.h"
#import "TLTrainStationTableViewDelegateAndDatasource.h"
#import "TLTrainStation.h"
#import "TLAppDelegate.h"
#import "TLMasterViewController.h"
#import "TLStationDetailViewController.h"

@interface TLSearchForStationViewController ()
{
  /// The datasource for the search stations view
  TLTrainStationTableViewDelegateAndDatasource* _searchViewDelegate;
}
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UISearchDisplayController *searchController;
@property (strong, nonatomic) IBOutlet UITableView *searchTable;

/**
 * Loads in the list of possible searchable stations
 * @return  An array of all names of stations in Melbourne.
 */
-(NSArray*) loadSearchableStations;

/**
 * Displays a standard UI alert with the given message
 * @param msg   Message to display
 * @param title Title for alert
 */
-(void) displayAlertWithMessage:(NSString*) msg title:(NSString*) title;

@end

@implementation TLSearchForStationViewController

#pragma mark - Setup

- (void)viewDidLoad
{
  [super viewDidLoad];

  // Initialise ivars if not initialised
  if (!_searchStations)
    _searchStations = [self loadSearchableStations];
  
  // Setup table view delegate and datasource with search stations data
  _searchViewDelegate = [[TLTrainStationTableViewDelegateAndDatasource alloc] initWithAnArrayOfStations:_searchStations allowsEditing:NO];
  
  // Set the data source and delegate to the delegate defined above
  [_searchTable setDataSource:_searchViewDelegate];
  [_searchTable setDelegate:_searchViewDelegate];
  
  // Set me as the delegate for the searchbar
  [_searchBar setDelegate:self];
  
  // Set _searchDDS as the delegate and data source for the search controller
  _searchController = [[UISearchDisplayController alloc]
                       initWithSearchBar:_searchBar contentsController:self];
  [_searchController setSearchResultsDataSource:_searchViewDelegate];
  [_searchController setSearchResultsDelegate:_searchViewDelegate];
  [_searchController setDelegate:self];
}


-(NSArray*) loadSearchableStations
{
  // Load in the stations
  TLAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
  NSURL* stationsPath = [appDelegate readMainBundleResourceWithName:@"melbourne_stations_list"
                                                                ofType:@"txt"];
  return [[NSString stringWithContentsOfURL:stationsPath encoding:NSUTF8StringEncoding error:nil]
           componentsSeparatedByString:@"\n"];
}

-(void) filterOutStations:(NSArray *)stationsToDisable
{
  if (!_searchStations)
    _searchStations = [self loadSearchableStations];
  
  _searchStations = [_searchStations filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"!(self IN %@.name)", stationsToDisable]];
}

#pragma mark - Helper Methods

-(void) displayAlertWithMessage:(NSString *)msg title:(NSString *)title
{
  UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title
                                                  message:msg
                                                 delegate:nil
                                        cancelButtonTitle:@"OK"
                                        otherButtonTitles:nil];
  [alert show];
}

#pragma mark - Search Bar Delegate

// If cancelling search, default back to original data for _searchDDS
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
  [_searchViewDelegate updateData:_searchStations];
}

// Update the _searchDDS to reflect changes in the the search
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
  NSMutableArray* retVal = [[NSMutableArray alloc] init];
  
  // Scan through _searchStatons for partial match
  for (NSString* stationName in _searchStations)
  {
    // Match found!
    if ([[stationName uppercaseString]
         rangeOfString:[searchText uppercaseString]].location != NSNotFound)
    {
      [retVal addObject:stationName];
    }
  }
  // Reinitalise the _searchDDS to reflect this information
  [_searchViewDelegate updateData:retVal];
  // Force override display sectiond data to off (i.e., don't aggregate if searching)
  [_searchViewDelegate setShouldSplitIntoSections:NO];
  [[_searchController searchResultsTableView] setDataSource:_searchViewDelegate];
  [[_searchController searchResultsTableView] setDelegate:_searchViewDelegate];
  [[_searchController searchResultsTableView] reloadData];
}


#pragma mark - Navigation

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  // Unwinding to Favourite Stations by adding new favourite station...
  if ([sender isKindOfClass:[UITableViewCell class]] &&
      [[segue identifier] isEqualToString:@"newFavouriteStation"])
  {
    // Get name of favourite station to search from cell...
    _lastTappedStationName =
      [_searchViewDelegate stationNameFromIndexPath:[_searchTable indexPathForCell:sender]];
  }
  // Getting info for station...
  else if ([sender isKindOfClass:[UITableViewCell class]] &&
      [[segue identifier] isEqualToString:@"getStationInfo"])
  {
    // Pass in to the destination the info I have...
    [(TLViewUsesStationData*)[segue destinationViewController] provideViewWithStationData:
     [_searchViewDelegate anyStationDataFromIndexPath:[_searchTable indexPathForCell:sender]]];
  }
}



@end
