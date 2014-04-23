#import "TLViewLoaderSpinner.h"

/// Class-maintained spinner
static UIActivityIndicatorView* spinner;

@interface TLViewLoaderSpinner ()
/// Internal access to a spinner
@property (readonly) UIActivityIndicatorView* spinner;
@end

@implementation TLViewLoaderSpinner

@synthesize spinner = _spinner;

-(id) initInView:(UIView *)view
{
  if (self = [super init])
  {
    // Create progress indicator
    _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    // Need to position frame in the middle...
    CGRect spinnerFrame = [_spinner frame];
    CGRect  myViewFrame  = [view frame];
    
    // Position halfway x and y relative to my view's width and height
    spinnerFrame.origin.x = myViewFrame.size.width  /2 - spinnerFrame.size.width / 2;
    spinnerFrame.origin.y = myViewFrame.size.height /2 - spinnerFrame.size.height;
    
    // Update the spinner's frame to spinnerFrame
    [_spinner setFrame:spinnerFrame];
    [_spinner setColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]];
    // Add the spinner to my main view
    [_spinner startAnimating];
    [view addSubview:_spinner];
  }
  return self;
}

+(id) loadSpinnerInView:(UIView*) view
{
  TLViewLoaderSpinner* retVal = [[TLViewLoaderSpinner alloc] initInView:view];
  spinner = [retVal spinner];
  return retVal;
}

-(void) stopSpinner
{
  [_spinner stopAnimating];
}

+(void) stopSpinner
{
  [spinner stopAnimating];
}

@end
