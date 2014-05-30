#import <UIKit/UIKit.h>
/**
 * Embeeded depart view controls lists
 * departure details in greater detail
 * @author  Alex Cummaudo
 * @date    2014-05-27
 */
@interface TLEmbeddedDepartViewController : UITableViewController
{
  NSTimer* _refreshTimer;
}
@property NSDate* departueTime;

@end
