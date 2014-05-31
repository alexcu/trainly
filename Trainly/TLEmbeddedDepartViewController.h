#import <UIKit/UIKit.h>
/**
 * Embedded depart view control lists departure details in
 * greater detail and allows action on departing train
 * @author  Alex Cummaudo
 * @date    2014-05-27
 */
@interface TLEmbeddedDepartViewController : UITableViewController
{
  NSTimer* _refreshTimer;
}
@property NSDate* departueTime;

@end
