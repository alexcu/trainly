#import "TLEmbeddedDepartViewController.h"

@interface TLEmbeddedDepartViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *notifySwitch;
@property (weak, nonatomic) IBOutlet UILabel *departTimeString;
/**
 * Works out departure timeout date string
 * @param  deptTime  The date to work out
 * @return  Timeout string
 */
- (NSString*)departureTimeoutStringFromDate:(NSDate*) deptTime;
/**
 * Updates the time til depart label
 */
- (void) updateTimeLabel;
/**
 * Sets up a local notication to ping the user
 * when the departure time of this train has
 * occured
 */
- (void) setupLocalNotification;
/**
 * Removes the local notification of the ping
 * when this particular train leaves
 */
- (void) tearDownLocalNotification;
/**
 * Checks if a local notification has been set for this
 * date by the app
 */
- (BOOL) localNotifiacationIsSetForDate:(NSDate*) date;
@end

@implementation TLEmbeddedDepartViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) viewDidDisappear:(BOOL)animated
{
  // Invaliate running timer
  [_refreshTimer invalidate];
  _refreshTimer = nil;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  // Update initial time label
  [self updateTimeLabel];
  
  // Set slider if notif is set
  [_notifySwitch setOn:[self localNotifiacationIsSetForDate:_departueTime]];
  
  _refreshTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                   target:self
                                                 selector:@selector(updateTimeLabel)
                                                 userInfo:nil
                                                  repeats:YES];
  // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Departs In Label

- (void) updateTimeLabel
{
  NSString* newStr = [self departureTimeoutStringFromDate:_departueTime];
  [_departTimeString setText:newStr];
}
                   
-(NSString*) departureTimeoutStringFromDate:(NSDate *)deptTime
{
  unsigned int unitFlags =  NSSecondCalendarUnit |
                            NSHourCalendarUnit |
                            NSMinuteCalendarUnit;
  NSDate* now = [NSDate date];
  NSCalendar *gregorian = [[NSCalendar alloc]
                           initWithCalendarIdentifier:NSGregorianCalendar];
  
  NSDateComponents *comps = [gregorian components:unitFlags fromDate:now  toDate:deptTime  options:0];
  
  NSInteger hrs = [comps hour];
  NSInteger min = [comps minute];
  NSInteger sec = [comps second];
  
  if (hrs == 0 && min == 0 && sec == 0)
  {
    [self tearDownLocalNotification];
    [_notifySwitch setOn:NO animated:YES];
  }
  NSString* hrsStr = hrs == 1 ? @"hr" : @"hrs";
  NSString* minStr = min == 1 ? @"min" : @"mins";
  NSString* secStr = sec == 1 ? @"sec" : @"secs";
  
  if (hrs <= 0 && min <= 0 && sec < 0)
  {
    [_notifySwitch setOn:NO animated:YES];
    [_notifySwitch setEnabled:NO];
    return @"Left";
  }
  else if (hrs > 0)
  {
    return [NSString stringWithFormat:@"%d %@", hrs, hrsStr];
  }
  else if (min > 0)
  {
    return [NSString stringWithFormat:@"%d %@ %d %@", min, minStr, sec, secStr];
  }
  else
  {
    return [NSString stringWithFormat:@"%d %@", sec, secStr];
  }
}

#pragma mark - Notify Switch

- (IBAction)didChangeNotifySwitch:(id)sender {
  
  BOOL shouldNotify = [_notifySwitch isOn];
  
  if (shouldNotify)
    [self setupLocalNotification];
  else
    [self tearDownLocalNotification];
  
}

- (void) setupLocalNotification
{
  // Setup notification on tap
  UILocalNotification* notif = [[UILocalNotification alloc] init];

  NSDateFormatter* dateToPrettyStr = [[NSDateFormatter alloc] init];
  [dateToPrettyStr setFormatterBehavior:NSDateFormatterBehavior10_4];
  [dateToPrettyStr setDateStyle:NSDateFormatterNoStyle];
  [dateToPrettyStr setTimeStyle:NSDateFormatterShortStyle];

  // Notification body
  NSString* notifBody = [NSString stringWithFormat:@"The %@ train has left.",
                         [dateToPrettyStr stringFromDate:_departueTime]];
  [notif setAlertBody:notifBody];
  [notif setFireDate:_departueTime];
  [[UIApplication sharedApplication] scheduleLocalNotification:notif];
}

- (void) tearDownLocalNotification
{
  for (UILocalNotification* n in [[UIApplication sharedApplication] scheduledLocalNotifications])
  {
    if ([[n fireDate] isEqualToDate:_departueTime])
    {
      // Cancel this notif
      [[UIApplication sharedApplication] cancelLocalNotification:n];
    }
  }
}

- (BOOL) localNotifiacationIsSetForDate:(NSDate*) date
{
  for (UILocalNotification* n in [[UIApplication sharedApplication] scheduledLocalNotifications])
  {
    if ([[n fireDate] isEqualToDate:date])
    {
      return YES;
    }
  }
  return NO;
}


@end
