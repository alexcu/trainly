#import <UIKit/UIKit.h>
/**
 * The Search for stations view gives the ability for users to search
 * and find new favourite stations that they wish to add to the home
 * screen view
 * @author  Alex Cummaudo
 * @date    2014-03-30
 */
@interface TLSearchForStationViewController : UITableViewController
  <UISearchBarDelegate, UISearchDisplayDelegate>
{
  /// The list of stations I will allow searching for
  NSArray*  _searchStations;
}

/**
 * Removes stations in the list of stations I display
 * @param stationsToDisable The stations to disable in the list
 */
-(void) filterOutStations:(NSArray*) stationsToDisable;

/// The station named that was tapped in the Search View Controller
@property (readonly) NSString* lastTappedStationName;

@end