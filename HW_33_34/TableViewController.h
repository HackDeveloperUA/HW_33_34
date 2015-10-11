
#import <UIKit/UIKit.h>

@interface TableViewController : UITableViewController



@property (strong, nonatomic) IBOutlet UITableView *tableView;

- (id) initWithFolderPath:(NSString*) path;

@end
