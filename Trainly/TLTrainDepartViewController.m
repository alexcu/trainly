#import "TLTrainDepartViewController.h"
#import <MapKit/MapKit.h>
#import "TLEmbeddedDepartViewController.h"
@interface TLTrainDepartViewController ()

@property (weak, nonatomic) IBOutlet MKMapView *departTrainMapView;
@property (weak, nonatomic) IBOutlet UIView *departureDetailView;

@end

@implementation TLTrainDepartViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  // Initialise the map delegate
  _displayStationDelegate = [[TLPinStationOnMapViewDelegate alloc] init];
  
  // Pass in the station info
  [_displayStationDelegate provideViewWithStationData:_trainStationData];
  [_departTrainMapView setDelegate:_displayStationDelegate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  // Pass in the date
  if ([[segue identifier] isEqualToString:@"EmbedDetailOptionsView"])
  {  [(TLEmbeddedDepartViewController*)[segue destinationViewController] setDepartueTime:_departureTime];
  }
}

@end
