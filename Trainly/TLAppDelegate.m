#import "TLAppDelegate.h"
#import <CoreData/CoreData.h>
#import "TLMasterViewController.h"
#import "TLViewUsesStationData.h"

/// The data model name for this app, assuming that there is
/// only to be one data model for this app.
static NSString* const DATA_MODEL_NAME = @"TrainlyDataModel";

@interface TLAppDelegate()
/**
 * Returns the URL to the document path for this app---
 * if the file does not exist one will be created.
 * @note  Use this for read/write file I/O
 */
-(NSURL*)applicationDocumentsPath;
@end

@implementation TLAppDelegate

#pragma mark - App Launch

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  // Pass in my MOC to first view controller...
  UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
  TLMasterViewController *controller = (TLMasterViewController *)navigationController.topViewController;
  controller.moc = self.moc;
  
  // Override point for customization after application launch.
  return YES;
}

#pragma mark - App Status Change

- (void)applicationWillResignActive:(UIApplication *)application
{
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Core Data Stack

/**
 * Getter for the moc for the app, creating the moc if it 
 * hasn't yet been initalised
 * @note    The moc (Managed Object Context) allows access to
 *          retrieve and save the Model
 * @return  The moc for this app
 */
-(NSManagedObjectContext*) moc
{
  // If _moc has already been initialised, then return the already
  // initialised _moc (Singleton Pattern; initialise once and once only!)
  if (_moc)
    return _moc;
  
  // If _moc is not yet initialised, initialise the persiatant store coordinator
  // and initialise all required Core Data ivars all the way down the stack
  NSPersistentStoreCoordinator* tmpPsc = [self psc];
  // Given the tmpPsc returned an initialised _psc
  if (tmpPsc)
  {
    // Now initialise _moc with the initialised psc
    _moc = [[NSManagedObjectContext alloc] init];
    [_moc setPersistentStoreCoordinator:tmpPsc];
  }
  
  // Return the new initialised moc
  return _moc;
}
/**
 * Getter for the mom for the app, creating the mom if it 
 * hasn't yet been initialised
 * @note    The mom (Managed Object Model) defines the 
 *          entities of this app and their relationships
 * @return  The mom of this app
 */
-(NSManagedObjectModel*) mom
{
  // If _mom has already been initialised, then return the already
  // initialised _mom (Singleton Pattern; initialise once and once only!)
  if (_mom)
    return _mom;
  
  // Otherwise load in the Model as declared in the DATA_MODEL_NAME file
  NSURL* modelDir = [[NSBundle mainBundle] URLForResource:DATA_MODEL_NAME
                                            withExtension:@"momd"];
  _mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelDir];
  
  // Return the loaded in model
  return _mom;
}
/**
 * Getter for the psc for the app, creating the psc if it
 * hasn't yet been initialised
 * @note    The psc (Persitant Store Coordinator) coordinates
 *          persistant storage to disk of the Model to a file.
 * @return  The psc of this app
 */
-(NSPersistentStoreCoordinator*) psc
{
  // If _psc has already been initialised, then return the already
  // initialised _psc (Singleton Pattern; initialise once and once only!)
  if (_psc)
    return _psc;
  
  // Otherwise load in the persitant `database' from disk
  // using binary storage
  NSURL* storageDir = [self applicationDocumentsPathWithFilename:@"TrainlyModel.dat"];
  
  NSError* ioError = nil;
  
  // Create the PSC
  _psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self mom]];
  [_psc addPersistentStoreWithType:NSBinaryStoreType
                     configuration:nil
                               URL:storageDir
                           options:nil
                             error:&ioError];
  
  // If there was a problem creating the PSC or there was an IO error...
  if (!_psc || ioError)
    // App cannot continue without access to its PSC! Abandon ship!
    [self handleError:ioError abort:YES];
  
  // Otherwise all good!
  return _psc;
}
-(void) saveContext
{
  NSError* saveError = nil;
  [_moc save:&saveError];
  
  // Error occured?
  if (saveError)
    [self handleError:saveError abort:NO];
}

#pragma mark - File I/O

-(NSURL*)applicationDocumentsPath
{
  // Get to the document paths for this app
  NSFileManager* fileMan = [[NSFileManager alloc] init];
  
  
  NSError* ioError = nil;
  
  // Get the directory of the application path
  NSURL* retVal = [fileMan URLForDirectory:NSDocumentDirectory
                                  inDomain:NSUserDomainMask
                         appropriateForURL:nil
                                    create:YES
                                     error:&ioError];
  
  // If there was an error, use this application's default error handler
  // to log it
  if (ioError)
    [self handleError:ioError abort:NO];
  
  return retVal;
}
-(NSURL*)applicationDocumentsPathWithFilename:(NSString*) fileName
{
  return [[self applicationDocumentsPath] URLByAppendingPathComponent:fileName];
}
-(NSURL*)readMainBundleResourceWithName:(NSString*)resName ofType:(NSString*)resType
{
  NSString* path = [[NSBundle mainBundle] pathForResource:resName ofType:resType];
  if (!path)
  {
    [self handleError:[NSError errorWithDomain:@"FileIO" code:0 userInfo:nil] abort:NO];
    return nil;
  }
  else
  {
    return [NSURL fileURLWithPath:path];
  }
}

#pragma mark - Error Handling

-(void) handleError:(NSError*) error abort:(BOOL) abortApp;
{
  NSLog(@"* Unresolved Error * %@: %@", error, [error userInfo]);
  
  if (abortApp)
  {
    NSLog(@"* Abandon Ship! *");
    abort();
  }
}

@end