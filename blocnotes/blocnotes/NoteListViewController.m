//
//  ViewController.m
//  blocnotes
//
//  Created by Casey Ward on 5/18/15.
//  Copyright (c) 2015 Casey Ward. All rights reserved.
//

#import "NoteListViewController.h"
#import "AppDelegate.h"
#import "Note.h"
#import "CreateNoteViewController.h"

@interface NoteListViewController () <NSFetchedResultsControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSFetchedResultsController *fetchRequestController;


@end

@implementation NoteListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //[self.fecthRequestController performFetch:NULL];
   
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.fetchRequestController performFetch:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"edit"]) {
        UITableViewCell *cell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        UINavigationController *navController = segue.destinationViewController;
        CreateNoteViewController *createNoteViewController = (CreateNoteViewController *)navController.topViewController;
        createNoteViewController.note = [self.fetchRequestController objectAtIndexPath:indexPath];
    }
}


#pragma mark - Table view data source
/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return self.fecthRequestController.sections.count;
}
*/


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.fetchRequestController.fetchedObjects.count;
    
    
}

 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
 
 // Configure the cell...
     //original configuration
     //cell.textLabel.text = [self.fecthRequestController.fetchedObjects[indexPath.row] valueForKey:@"title"];
     Note  *note = [self.fetchRequestController objectAtIndexPath:indexPath];
     cell.textLabel.text = note.title;
     return cell;
}

-(UITableViewCellEditingStyle)tableView: (UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    Note *note = [self.fetchRequestController objectAtIndexPath:indexPath];
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [[appDelegate managedObjectContext] deleteObject:note];
    [appDelegate saveContext];
}
/*
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 DiaryEntry *entry = [self.fetchedResultsController objectAtIndexPath:indexPath];
 CoreDataStack *dataStack = [CoreDataStack defaultStack];
 [[dataStack managedObjectContext] deleteObject:entry];
 [dataStack saveContext];
 }

 */


#pragma mark - Fetch Request Definition

-(NSFetchRequest *)noteListFetchRequest{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Note"];
    fetchRequest.sortDescriptors =@[[NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending:NO]];
    
    return fetchRequest;
}

-(NSFetchedResultsController *)fetchRequestController{
    if (_fetchRequestController != nil) {
        return _fetchRequestController;
    }
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSFetchRequest *fetchRequest = [self noteListFetchRequest];
    
    _fetchRequestController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:appDelegate.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    _fetchRequestController.delegate = self;
    return _fetchRequestController;
}



-(void) controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

-(void) controllerWillChangeContent:(NSFetchedResultsController *)controller{
    [self.tableView beginUpdates];
}

-(void) controllerDidChangeContent:(NSFetchedResultsController *)controller {
    //[self.tableView reloadData];
    [self.tableView endUpdates];
}



/*
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
 
 // Configure the cell...
 
 return cell;
 }
 */


@end
