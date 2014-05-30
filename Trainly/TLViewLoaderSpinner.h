#import <Foundation/Foundation.h>

/**
 * The loader spinner is a easy and convenient manager to
 * add a UIActivityIndicatorView to the foreground of the
 * front-most view.
 * @author  Alex Cummaudo
 * @date    2014-03-28
 */
@interface TLViewLoaderSpinner : NSObject
{
  /// The spinner itself
  UIActivityIndicatorView* _spinner;
}

/**
 * Creates a please wait spinner in the given view
 * @param view  The view to put the please wait spinner in
 */
-(id) initInView:(UIView*) view;

/**
 * Places the spinner in the view and keeps it alive so long as it is stopped
 * @param view  The view to put the please wait spinner in
 */
+(id) loadSpinnerInView:(UIView*) view;

/**
 * Stops and removes the spinner
 */
-(void) stopSpinner;

/**
 * Stops spinner from class based
 */
+(void) stopSpinner;

@end
