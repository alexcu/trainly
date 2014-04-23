#import <UIKit/UIKit.h>

/**
 * Trainly App Delegate
 * @author  Alex Cummaudo
 * @date    2014-04-04
 */
@interface TLAppDelegate : UIResponder <UIApplicationDelegate>
{
  #pragma mark - Core Data ivars
  NSManagedObjectContext*       _moc;
  NSManagedObjectModel*         _mom;
  NSPersistentStoreCoordinator* _psc;
}

#pragma mark - Main Window

@property (strong, nonatomic) UIWindow *window;

#pragma mark - Core Data

@property (readonly, strong, nonatomic) NSManagedObjectContext*       moc;
@property (readonly, strong, nonatomic) NSManagedObjectModel*         mom;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator* psc;

/**
 * Invoke to save all changes made to the MOC
 */
-(void) saveContext;

#pragma mark - File IO

/**
 * Returns a URL to a filename provided stored in the User Domain Mask
 * under this app's user document directory
 * @note  Use this for read/write file I/O
 * @param fileName  The filename to retrieve
 * @return          The filename path of this document
 */
-(NSURL*)applicationDocumentsPathWithFilename:(NSString*) fileName;

/**
 * Returns a URL to a main bundle resource
 * @note    Use this for reading app resources
 * @param   resName The name of this resource
 * @param   resType The extension of this resource
 * @return  The URL of this resource
 */
-(NSURL*)readMainBundleResourceWithName:(NSString*)resName ofType:(NSString*)resType;

#pragma mark - Error Handling

/**
 * Handles an error in a default way for this application
 * @param error     The error to handle
 * @param abortApp  Whether or not this error should abort the app
 */
-(void) handleError:(NSError*) error abort:(BOOL) abortApp;


@end
