
#import "TableViewController.h"
#import "CustomFolderCell.h"
#import "CustomFileCell.h"

@interface TableViewController ()

@property (strong, nonatomic) NSDictionary* nameImageDict;

@property (strong, nonatomic) NSArray*  contents;
@property (strong, nonatomic) NSMutableArray* arrayForFolder;
@property (strong, nonatomic) NSMutableArray* arrayForFile;

@property (strong, nonatomic) NSString* path;

@end


@implementation TableViewController


- (id) initWithFolderPath:(NSString*) path
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.path = path;
    }
    
    return self;
}


- (void) setPath:(NSString *)path {
    
    _path = path;
    NSError* error = nil;
    self.contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_path
                                                                        error:&error];
    [self sortingArray];
    
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    [self.tableView reloadData];
    self.navigationItem.title = [self.path lastPathComponent];
}




- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray*  paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths firstObject];
    
    
    if (!self.path) {
        self.path = documentsDirectory;
    }

    [self showPath];
    
    
    NSDictionary* dict = [[NSDictionary alloc] init];
    
    dict = @{@"zip" : @"iconZIP",
             @"png":  @"iconPNG",
             @"doc":  @"iconDoc",
             @"html": @"iconHTML",
             @"jpg" : @"iconJPG",
             @"mp4" : @"iconVideo",
             @"mp3" : @"iconMP3",
             @"pdf" : @"iconPDF",
             @"txt" : @"iconTxt",
             @"avi" : @"iconVideo"};
    
    self.nameImageDict = dict;
    
    
    UIBarButtonItem* itemAddFolder  =  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                     target:self
                                                                                     action:@selector(actionAddFolder:)];
    
    self.navigationItem.rightBarButtonItem = itemAddFolder;
}


- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    if ([self.navigationController.viewControllers count] > 1) {
        UIBarButtonItem* itemBackToRoot =  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                         target:self
                                                                                         action:@selector(actionBackToRoot:)];
        NSMutableArray* createdButtons = [NSMutableArray arrayWithArray:self.navigationItem.rightBarButtonItems];
        [createdButtons addObject:itemBackToRoot];
        self.navigationItem.rightBarButtonItems = (NSArray*)createdButtons;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Helper Methods 

- (BOOL) isDirectoryAtIndexPath:(NSIndexPath*) indexPath {
    
    NSString* fileName = [self.contents objectAtIndex:indexPath.row];
    NSString* filePath = [self.path stringByAppendingPathComponent:fileName];
    
    BOOL isDirectory = YES;
    
    [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];
    return isDirectory;
}



- (NSString*) fileSizeFromValue:(unsigned long long) size {
    
    static NSString* units[] = {@"B", @"KB", @"MB", @"GB", @"TB"};
    static int unitsCount = 5;
    
    int index = 0;
    
    double fileSize = (double)size;
    
    while (fileSize > 1024 && index < unitsCount) {
        fileSize /= 1024;
        index++;
    }
    return [NSString stringWithFormat:@"%.2f %@", fileSize, units[index]];
}


-(void) showPath {
    
    NSString* documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)firstObject];
    NSString* temporaryDirectory = NSTemporaryDirectory();
    NSString* homeDirectory      = NSHomeDirectory();
    
    
    NSLog(@"documentsDirectory = %@",documentsDirectory);
    NSLog(@"temporaryDirectory = %@",temporaryDirectory);
    NSLog(@"homeDirectory      = %@",homeDirectory);
    
}


-(NSString*) setImageName:(NSIndexPath*) indexPath {
    
    NSString* pathFile    = [self.path stringByAppendingPathExtension:[self.contents objectAtIndex:indexPath.row]];
    NSString* extension   = [pathFile pathExtension];

    NSString* nameImage = [self.nameImageDict valueForKey:extension];

    if (nameImage) {
        return nameImage;
    }
    else {
        return @"iconDefault";
    }
    
    return nil;
}


-(void) sortingArray {
    
    NSMutableArray* folder = [NSMutableArray new];
    NSMutableArray* file   = [NSMutableArray new];

    for (int i=0; i<[self.contents count]; i++) {
       
        NSIndexPath *index = [NSIndexPath indexPathForRow:i inSection:0] ;
       
        // Bытаскиваем скрытые файлы из таблицы
        NSString* str = [self.contents objectAtIndex:i];
        
        if ([[str substringToIndex:1] isEqualToString:@"."]) {
            NSMutableArray* array = [NSMutableArray arrayWithArray:self.contents];
            [array removeObjectAtIndex:i];
            self.contents = (NSArray*)array;
        }
        
        
        if ([self isDirectoryAtIndexPath:index]) {
            [folder addObject:[self.contents objectAtIndex:i]];
        }
        else {
            [file addObject:[self.contents objectAtIndex:i]];
        }
    }
    self.arrayForFolder = folder;
    self.arrayForFile   = file;
    
    [self.arrayForFolder arrayByAddingObjectsFromArray:self.arrayForFile];
    self.contents=[_arrayForFolder arrayByAddingObjectsFromArray:_arrayForFile];
}




- (void) actionAddFolder:(UIBarButtonItem*) sender {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Creat Directory:" message:@"Please enter your folder:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
    
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag = 12;
    
    [alert addButtonWithTitle:@"Create"];
    [alert show];


}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 12 && buttonIndex == 1) {
        
        
        UITextField *textfield = [alertView textFieldAtIndex:0];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString      *path  = [self.path stringByAppendingPathComponent:textfield.text];
        
        if (![fileManager fileExistsAtPath:path]) {
            [fileManager createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:nil];
        }
        self.contents  = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_path
                                                                             error:nil];
        [self sortingArray];
        [self.tableView reloadData];
    }
}


- (void) actionBackToRoot:(UIBarButtonItem*) sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
 
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.contents count];
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *fileIdentifier   = @"fileCell";
    static NSString *folderIdentifier = @"folderCell";
    
    NSString* fileName = [self.contents objectAtIndex:indexPath.row];
    
    
    if ([self isDirectoryAtIndexPath:indexPath]) {
    
        NSString* path = [self.path stringByAppendingPathComponent:fileName];
        
        NSDictionary* attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
        
        CustomFolderCell *cell = (CustomFolderCell*)[tableView dequeueReusableCellWithIdentifier:folderIdentifier];

        NSString* nameImage = [NSString new];
        
        if ([attributes fileSize]>68.f) {
            nameImage = @"iconFolderFull";
        }
        else {
            nameImage = @"iconFolderEmpty";
        }
        
        cell.imageFolder.image = [UIImage imageNamed:nameImage];
        cell.nameLable.text = fileName;
        cell.sizeLable.text = [self fileSizeFromValue:[attributes fileSize]];
      
   
        
        static NSDateFormatter* dateFormatter = nil;
        
        if (!dateFormatter) {
            dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"MM/dd/yyyy hh:mm a"];
        }
        
        cell.dateLable.text = [dateFormatter stringFromDate:[attributes fileModificationDate]];

        return cell;
  
        
    } else {
        
        NSString* path = [self.path stringByAppendingPathComponent:fileName];
        
        NSDictionary* attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
        
        CustomFileCell *cell = (CustomFileCell*)[tableView dequeueReusableCellWithIdentifier:fileIdentifier];
        
       
        NSString* str = [self setImageName:indexPath];

        cell.imageFile.image = [UIImage imageNamed:str];
        cell.nameLable.text  = fileName;
        cell.sizeLable.text  = [self fileSizeFromValue:[attributes fileSize]];
        
        static NSDateFormatter* dateFormatter = nil;
        
        if (!dateFormatter) {
            dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"MM/dd/yyyy hh:mm a"];
        }
        
        cell.dateLable.text = [dateFormatter stringFromDate:[attributes fileModificationDate]];
        
        return cell;
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self isDirectoryAtIndexPath:indexPath]) {
        return 60.f;
    } else {
        return 55.f;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self isDirectoryAtIndexPath:indexPath]) {
        
        NSString* fileName = [self.contents objectAtIndex:indexPath.row];
        
        NSString* path = [self.path stringByAppendingPathComponent:fileName];
  
        TableViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"TableViewController"];
        vc.path = path;
        [self.navigationController pushViewController:vc animated:YES];
    }
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {    
    return YES;
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewCellEditingStyleDelete;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSFileManager* fileManager =[NSFileManager defaultManager];
        NSString*   str = self.path;
        NSString*   str2 = [str stringByAppendingPathComponent:[self.contents objectAtIndex:indexPath.row]];
        
        if ([fileManager fileExistsAtPath:str2]) {
       
        NSMutableArray* array = [NSMutableArray arrayWithArray:self.contents];
                        
        [array removeObjectAtIndex:indexPath.row];
        [fileManager removeItemAtPath:str2 error:nil];
        self.contents = array;
        [self sortingArray];
        
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
        [tableView endUpdates];
        }
    }
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
