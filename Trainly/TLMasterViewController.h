#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "TLViewPerformsAddingFavouriteStationRequest.h"

// Forward Declaration
@class TLTrainStation;

@interface TLMasterViewController: UIViewController
  <TLViewPerformsAddingFavouriteStationRequest>
{
  /// The list of favourite stations
  NSArray*             _favouriteStations;
  /// The moc for accessing favourite train stations
  NSManagedObjectContext*     _moc;
  /// Whether or not favourites are in editing more
  BOOL _isInEditFavouritesMode;
}

/**
 * Adds a new train station to the favourites list
 * @param trainStation  The station to add---can either be a TLTrainStation or
 *                      an NSDictionary denoting the key value pairs for this
 *                      train station object.
 */
-(void) newFavouriteStation:(id) trainStation;

@property NSManagedObjectContext* moc;

@end
