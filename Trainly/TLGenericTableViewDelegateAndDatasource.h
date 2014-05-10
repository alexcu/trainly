#import <Foundation/Foundation.h>

/**
 * This class handles a Table View and its data source.
 * Initialise this class with the data and set this class
 * as a delegate and datasource for a Table View
 * @author  Alex Cummaudo
 * @date    2014-03-28
 */
@interface TLGenericTableViewDelegateAndDatasource : NSObject
  <UITableViewDelegate, UITableViewDataSource>
{
  /// The data for each section in the table source
  NSArray*  _sectionData;
  /// The section identifiers
  NSArray*  _sectionIDs;
}

/**
 * Initialises the delegate with section data.
 * @param data        Data for each section
 * @param sectionIDs  Matching cell identifiers for each section
 */
-(id) initWithSectionData:(NSArray*) data sectionIdentifiers:(NSArray*) sectionIDs;

/**
 * Initialises the delegate with one section, its data provided here
 * @param data        Data for the single section.
 * @param sectionID   The reusable cell identifier for this section's cells
 */
-(id) initWithOneSectionData:(NSArray*) data sectionIdentifier:(NSString*) sectionID;

/**
 * Makes a cell with the given index path have an activity indicator
 * @param tableView The table view for to set the cell for
 * @param indexPath Cell that the activity indicator should be set at
 */
-(void) tableView:(UITableView*) tableView addActivityIndicatorForCellAtIndexPath:(NSIndexPath*) indexPath;

@end
