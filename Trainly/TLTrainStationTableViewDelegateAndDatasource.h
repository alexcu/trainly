#import "TLGenericTableViewDelegateAndDatasource.h"
#import "TLViewPerformsStationGetInfoRequest.h"

// Forward declare
@class TLTrainStation;

/**
 * This class is a Table View datasource and delegate 
 * for an array of train stations.
 *
 * @author  Alex Cummaudo
 * @date    2014-03-28
 */
@interface TLTrainStationTableViewDelegateAndDatasource : TLGenericTableViewDelegateAndDatasource
  <UITableViewDelegate, UITableViewDataSource>
{
  /// Internal state whether or not the Table View should split the number
  /// of stations into sections ordered alphabetically
  BOOL _shouldSplitIntoSections;
  /// The list of station names I should display
  NSArray* _stationNames;
  /// The list of stations I have
  NSArray* _stations;
  /// Whether or not the datasource allows for editing
  BOOL _allowsEditing;
}

/// The sections managed by this delegate
@property (readonly) NSIndexSet* sections;

/**
 * Intialises this delegate/datasource object with an array of train
 * station objects, and the view controller that is managing the table
 * view.
 * @param stations        The stations to initialise this with
 * @param viewController  The view controller that manages this table view
 * @param allowsEditing   Whether or not the stations can be edited
 */
-(id) initWithAnArrayOfStations:(NSArray*) stations
             fromViewController:(UIViewController*) viewController
                  allowsEditing:(BOOL) editing;

/**
 * Updates the data displayed if changes were made
 * @param data The new data source
 */
-(void) updateData:(NSArray*) data;

/**
 * Finds the Train Station object at the given index path
 * @param   indexPath The index path to find at
 * @return  The station at this index path, or nil if there isn't a station there
 */
- (TLTrainStation*) stationFromIndexPath:(NSIndexPath *)indexPath;

/**
 * Gets the station name at the given index path
 * @param   indexPath  The index path to get
 * @return  The station name at this index path
 */
-(NSString*) stationNameFromIndexPath:(NSIndexPath*) indexPath;

/**
 * Gets any station data from the cell at the given index path
 * @param   indexPath  The index path to get
 * @return  A TLTrainStation or NSString with the station name
 */
- (id) anyStationDataFromIndexPath:(NSIndexPath*) indexPath;

/**
 * Gets the station name at the given index path
 * @param   name  The station to get
 * @return  The cell of the station with this name
 */
-(UITableViewCell*) tableView:(UITableView *)tableView cellForStationWithName:(NSString*) name;

/// Determines whether or not the datasource should split stations into alphabetic
/// sections. Automatically determined by default, but can be overriden.
@property (nonatomic) BOOL shouldSplitIntoSections;

@end