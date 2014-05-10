#import "TLMasterViewController.h"
#import "TLStationDirectionViewController.h"
#import "TLTrainStationTableViewDelegateAndDatasource.h"
#import "TLTrainStation.h"
#import "TLViewUsesStationData.h"
#import "TLAppDelegate.h"
#import "TLSearchForStationViewController.h"
#import "TLPTVRequest.h"
#import "TLViewLoaderSpinner.h"
/**
 * @author  Alex Cummaudo
 * @date    2014-03-28
 */
@interface TLMasterViewController ()
{
  /// The delegate for the favourites table view
  TLTrainStationTableViewDelegateAndDatasource* _favouritesTableViewDelegate;
  /// Add requests to retain them
  NSMutableArray* _requests;
}
/// Table view for the favourite stations
@property (strong, nonatomic) IBOutlet UITableView *favouritesTableView;
/**
 * Unwind to the Favourite Stations list from elsewhere and reload favourite
 * data segue
 * @param segue The segue that caused this
 */
-(IBAction)unwindByCancellingToFavouriteStations:(UIStoryboardSegue *)segue;
/**
 * Unwind to the Favourite Stations list from elsewhere and reload favourite 
 * data segue
 * @param segue The segue that caused this
 */
-(IBAction)unwindByReloadingFavouriteStationData:(UIStoryboardSegue *)segue;
/**
 * Unwind to the Favourite Stations list from elsewhere with an alert message
 * segue
 * @param segue The segue that caused this
 * @param alert The alert view to display
 */
-(IBAction)unwindByWarningUser:(UIStoryboardSegue *)segue withAlertMessage:(UIAlertView*) alert;
/**
 * Unfavourites a station from notificiation of table view delegate
 * @param notification The notificiation that sent the unfavourite req
 */
-(void) unfavouriteStationFromNotificiation:(NSNotification*) notification;
/**
 * Changes the table for editing mode
 */
-(IBAction) didChangeFavouritesEditableMode:(id) sender;
/**
 * Checks if the station provided already exists in persistent storage
 * @param   trainStation  The station to check
 * @return                YES if it does, NO otherwise
 */
-(BOOL) stationAlreadyPersistant:(TLTrainStation*)trainStation;
/**
 * Prepares the view passed in with a train station required
 * @param view  The view that is this segue is about to go to.
 *              Must implement TLTrainStationDisplayableView
 * @param station The station to provide for this view
 */
-(void)segueForView:(TLViewUsesStationData*) view thatRequiresATrainStaion:(TLTrainStation*) station;
@end

@implementation TLMasterViewController

#pragma mark - Property Synthesis

@synthesize moc = _moc;

#pragma mark - Setup

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Initialise ivars
  _favouriteStations = [self loadFavouriteStations];
  _favouritesTableViewDelegate = [[TLTrainStationTableViewDelegateAndDatasource alloc]
                                  initWithAnArrayOfStations:_favouriteStations
                                  allowsEditing:YES];
  // Set the data source and delegate to the delegate defined above
  [_favouritesTableView setDataSource:_favouritesTableViewDelegate];
  [_favouritesTableView setDelegate:_favouritesTableViewDelegate];
  
  // Whether or not in edit favourites mode
  _isInEditFavouritesMode = NO;
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

/**
 * Loads the favourite stations
 */
-(NSArray*) loadFavouriteStations
{
  // Initate fetch request from _moc
  NSFetchRequest *favouritesLoadFetchReq = [[NSFetchRequest alloc] init];
  // Edit the entity name as appropriate.
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"TrainStation"
                                            inManagedObjectContext:_moc];
  [favouritesLoadFetchReq setEntity:entity];
  // Requires sort descriptor (use name ascending)
  [favouritesLoadFetchReq setSortDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"name"
                                                                           ascending:YES]]];
  
  // Ensure we load favourites only
  [favouritesLoadFetchReq setPredicate:[NSPredicate predicateWithFormat:@"self.isFavourite = YES"]];
  
  // Edit the section name key path and cache name if appropriate.
  // nil for section name key path means "no sections".
  NSFetchedResultsController *favouritesContainer =
  [[NSFetchedResultsController alloc] initWithFetchRequest:favouritesLoadFetchReq
                                      managedObjectContext:_moc
                                        sectionNameKeyPath:nil
                                                 cacheName:@"Favourites"];
  
  // Execute the fetch (Let app delegate handle error)
  NSError* error = nil;
  if (![favouritesContainer performFetch:&error])
  {
    TLAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    // Abort if favourites cannot be loaded!
    [appDelegate handleError:error abort:YES];
  }
  
  return [favouritesContainer fetchedObjects];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  // Cancel all PTV requests and nilify the requests
  [TLPTVRequest flushRequests];
  [_requests removeAllObjects];
  
  id dst = [segue destinationViewController];
  // If destination view requires a train station, pass in the station station
  // just tapped
  if ([dst isKindOfClass:[TLViewUsesStationData class]])
  {
    // Try to get a Train Station object itself...
    id trainStation = [_favouritesTableViewDelegate anyStationDataFromIndexPath:
                       [_favouritesTableView indexPathForCell:sender]];
    [self segueForView:dst thatRequiresATrainStaion:trainStation];
  }
  // Run according segue destination or segue identifier
  if ([[segue identifier] isEqualToString:@"searchForStations"])
    [self segueForNewFavouriteStationSearchViewController:[dst viewControllers][0]];
}

#pragma mark - Push Segues

-(void)segueForView:(TLViewUsesStationData*) view thatRequiresATrainStaion:(TLTrainStation*) station
{

    // Set the title to the item that was just tapped
    [view provideViewWithStationData:station];
}

-(void)segueForNewFavouriteStationSearchViewController:(TLSearchForStationViewController*) view
{
  // Gray out the favourite stations (i.e., we can't re-add them)
  [view filterOutStations:[self loadFavouriteStations]];
}

#pragma mark - Unwind Segues

-(void) unwindByCancellingToFavouriteStations:(UIStoryboardSegue *)segue {}
-(void) unwindByReloadingFavouriteStationData:(UIStoryboardSegue *)segue
{
  // Show spinner & hide table
  [TLViewLoaderSpinner loadSpinnerInView:[self view]];
  [_favouritesTableView setHidden:YES];
  // Disable editing for items now
  [[[self navigationItem] rightBarButtonItem] setEnabled:NO];
  [[[self navigationItem] leftBarButtonItem] setEnabled:NO];
  
  // Get station name
  NSString* tappedStationName = [[segue sourceViewController] lastTappedStationName];
  const SEL successSelector = @selector(didSuccessfullyRecieveDataForAddingNewFavouriteStation:);
  const SEL failureSelector = @selector(didFailInTryingToGetDataForNewFavouriteStation:);
  // In order to add the new favourite station, I need to know more about it---
  // for me to know more about it I'll need to send a get info request
  [TLPTVRequest requestStationSearch:tappedStationName
                          successSel:successSelector
                          failureSel:failureSelector
                              sender:self];
}
-(void) unwindByWarningUser:(UIStoryboardSegue *)segue withAlertMessage:(UIAlertView *)alert
{
  [alert show];
}

#pragma mark - Favourite Stations Editing

-(BOOL) stationAlreadyPersistant:(TLTrainStation*)trainStation
{
  // Initate fetch request from _moc
  NSFetchRequest *checkExistFetch = [[NSFetchRequest alloc] init];
  // Edit the entity name as appropriate.
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"TrainStation"
                                            inManagedObjectContext:_moc];
  [checkExistFetch setEntity:entity];
  // Requires sort descriptor (use name ascending)
  [checkExistFetch setSortDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"name"
                                                                           ascending:YES]]];
  // Check if stop id already exists
  [checkExistFetch setPredicate:[NSPredicate
                                        predicateWithFormat:@"self.stopID = %@", trainStation.stopID]];
  
  // Edit the section name key path and cache name if appropriate.
  // nil for section name key path means "no sections".
  NSFetchedResultsController *checkExistenceContainer =
  [[NSFetchedResultsController alloc] initWithFetchRequest:checkExistFetch
                                      managedObjectContext:_moc
                                        sectionNameKeyPath:nil
                                                 cacheName:@"Favourites"];
  
  // Execute the fetch (Let app delegate handle error)
  NSError* error = nil;
  if (![checkExistenceContainer performFetch:&error])
  {
    TLAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    // Abort if favourites cannot be loaded!
    [appDelegate handleError:error abort:YES];
  }
  
  return [[checkExistenceContainer fetchedObjects] count] > 0;
}

-(void) newFavouriteStation:(TLTrainStation*)trainStation
{
  NSLog(@"%d", [self stationAlreadyPersistant:trainStation]);
  // Insert new favourite stations in MOC if it doesnt already exist
  if (![self stationAlreadyPersistant:trainStation])
    [_moc insertObject:trainStation];
  
  NSError* error = nil;
  
  // Force favourite on trainStation
  [trainStation setIsFavourite:YES];
  
  // Update to reflect changes
  if (![_moc save:&error])
  {
    TLAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    // Abort if favourites cannot be saved!
    [appDelegate handleError:error abort:YES];
  }
  
  _favouriteStations = [self loadFavouriteStations];
  [_favouritesTableViewDelegate updateData:_favouriteStations];
  [_favouritesTableView reloadData];
}

#pragma mark - TLViewPerformsAddingFavouriteStationRequest Protocol Implementation

-(void) didSuccessfullyRecieveDataForAddingNewFavouriteStation:(NSNotification *)notification
{
  // No longer need to listen for notifications
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:[notification name]
                                                object:nil];
  // Show table
  [TLViewLoaderSpinner stopSpinner];
  [_favouritesTableView setHidden:NO];
  // Allow editing now
  // Disable editing for items now
  [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
  [[[self navigationItem] leftBarButtonItem] setEnabled:YES];
  
  NSArray* data = [notification userInfo][@"data"];
  // Add in the new station...
  TLTrainStation* newFavouriteStation =
    [[TLTrainStation alloc] initWithEntity:
     [NSEntityDescription entityForName:@"TrainStation" inManagedObjectContext:_moc]
            insertIntoManagedObjectContext:_moc];
  [newFavouriteStation setValuesForKeysWithDictionary:data[0]];
  [self newFavouriteStation:newFavouriteStation];
}

-(void) didFailInTryingToGetDataForNewFavouriteStation:(NSNotification *)notification
{
  // Stop trying
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:[notification name]
                                                object:nil];
  NSError* error = [notification userInfo][@"data"];
  
  // Show table
  [TLViewLoaderSpinner stopSpinner];
  [_favouritesTableView setHidden:NO];
  
  // Allow editing now
  // Disable editing for items now
  [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
  [[[self navigationItem] leftBarButtonItem] setEnabled:YES];
  
  // Lowercase the first letter in the error desc
  NSString* errorDesc = [[error userInfo] objectForKey:@"NSLocalizedDescription"];
  NSRange firstLetter;
  firstLetter.location = 0;
  firstLetter.length = 1;
  NSString* prettyErrorDesc =
  [errorDesc stringByReplacingCharactersInRange:firstLetter
                                     withString:[[errorDesc substringWithRange:firstLetter] lowercaseString]];
  
  // Setup message to display
  NSString* messageToDisplay = [NSString stringWithFormat:@"Can't add new favourite station since %@", prettyErrorDesc];
  
  // Show alert for error message
  [[[UIAlertView alloc] initWithTitle:@"Adding Favourite"
                              message:messageToDisplay
                             delegate:nil
                    cancelButtonTitle:@"OK"
                    otherButtonTitles:nil] show];
  
}

#pragma mark - Unfavouriting stations (but keeping it in cached memory!)

-(IBAction) didChangeFavouritesEditableMode:(id) sender
{
  // Toggle state
  _isInEditFavouritesMode = !_isInEditFavouritesMode;

  // Set state of table to reflect mode
  [_favouritesTableView setEditing:_isInEditFavouritesMode animated:YES];
  
  // Disable adding of stations
  [[[self navigationItem] rightBarButtonItem] setEnabled:!_isInEditFavouritesMode];
  
  // Decide if we should begin or end editing
  UIBarButtonSystemItem newMode;
  if (_isInEditFavouritesMode)
  {
    // Begin updating table
    [_favouritesTableView beginUpdates];
    newMode = UIBarButtonSystemItemDone;
    // Start listening for deletion notifications from delegate only
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(unfavouriteStationFromNotificiation:)
                                                 name:@"killFavourite"
                                               object:_favouritesTableViewDelegate];
  }
  else
  {
    [_favouritesTableView endUpdates];
    newMode = UIBarButtonSystemItemEdit;
    // Stop listentening to noficiations from delegate to kill
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"killFavourite"
                                                  object:_favouritesTableViewDelegate];
  }
  
  // Create new LHS button
  UIBarButtonItem* newButton =
  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:newMode
                                                target:self
                                                action:@selector(didChangeFavouritesEditableMode:)];
  [[self navigationItem] setLeftBarButtonItem:newButton animated:YES];
  
}

-(void) unfavouriteStationFromNotificiation:(NSNotification*) notification
{
  NSIndexPath* indexPath = [notification userInfo][@"indexPath"];
  TLTrainStation* stationToKill = [notification userInfo][@"station"];
  [stationToKill setIsFavourite:NO];
  
  NSError* error = nil;
  
  // Update to reflect changes
  if (![_moc save:&error])
  {
    TLAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    // Abort if favourites cannot be saved!
    [appDelegate handleError:error abort:YES];
  }
  
  _favouriteStations = [self loadFavouriteStations];
  [_favouritesTableViewDelegate updateData:_favouriteStations];
  
  // Delete the row
  [_favouritesTableView deleteRowsAtIndexPaths:@[indexPath]
                              withRowAnimation:UITableViewRowAnimationLeft];
  
  [_favouritesTableView endUpdates];
  [_favouritesTableView beginUpdates];
}

@end
