//
//  ViewController.m
//  blocnotes
//
//  Created by Casey Ward on 5/18/15.
//  Copyright (c) 2015 Casey Ward. All rights reserved.
//

#import "NoteListViewController.h"
#import "CoreDataStack.h"
#import "Note.h"
#import "NoteViewController.h"





@interface NoteListViewController () <NSFetchedResultsControllerDelegate, UISearchDisplayDelegate, UISearchBarDelegate, UISearchResultsUpdating>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSFetchedResultsController *fetchRequestController;
@property (strong, nonatomic) NSArray *filteredList;
@property (strong, nonatomic) NSFetchRequest *searchFetchRequest;
@property (retain, nonatomic) UISearchController *searchController;//retain instead of strong?

@end

@implementation NoteListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //[self.fecthRequestController performFetch:NULL];
    
    //searching
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    self.searchController.searchBar.scopeButtonTitles = @[];
                                                        
    self.searchController.searchBar.delegate = self;
    
    self.tableView.tableHeaderView = self.searchController.searchBar;
    //self.tableView.contentInset = UIEdgeInsetsMake(kHeightOfTableViewCells, 0, 0, 0);
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    //Do I try and load the sharedExtension
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.caseyward.blocnotes.extensionSharing"];
    
    
    [sharedDefaults objectForKey:@"stringKey"];
    
    [self.fetchRequestController performFetch:nil];
}

- (void)didReceiveMemoryWarning {
    
    self.searchFetchRequest = nil;
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"edit"]) {
        UITableViewCell *cell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        NoteViewController *createNoteViewController = (NoteViewController *)segue.destinationViewController;
        if (self.searchController.isActive) {
            //need to grab searchresults cell here -- similar to one below...
            createNoteViewController.note = [self.filteredList objectAtIndex:indexPath.row];
        }
            createNoteViewController.note = [self.fetchRequestController objectAtIndexPath:indexPath];
    }
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
////   
////    if (self.searchController.isActive) {
////        UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
////        [self performSegueWithIdentifier:@"edit" sender:cell];
////        
////    }
//}

#pragma mark - Table view data source
/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return self.fecthRequestController.sections.count;
}
*/


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    
    //if (tableView == self.tableView)
    //if (![self.searchController.searchBar.text  isEqual: @""]) {
    if (self.searchController.active) {
        return [self.filteredList count];
       
    } else {
        return self.fetchRequestController.fetchedObjects.count;
    }
    
    
}

 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     
     UITableViewCell *cell = nil;
     
     if (self.searchController.active) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        Note  *note = [self.filteredList objectAtIndex:indexPath.row];
        cell.textLabel.text = note.title;
         
     } else {
         cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
         Note  *note = [self.fetchRequestController objectAtIndexPath:indexPath];
         cell.textLabel.text = note.title;
     }
     
     return cell;
    
     
}

-(UITableViewCellEditingStyle)tableView: (UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    Note *note = [self.fetchRequestController objectAtIndexPath:indexPath];
    CoreDataStack *coreDataStack = [CoreDataStack defaultStack];
    [[coreDataStack managedObjectContext] deleteObject:note];
    [coreDataStack saveContext];
}


#pragma mark - Searching


- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *searchString = searchController.searchBar.text;
    [self searchForText:searchString];
    [self.tableView reloadData];
}


- (void)searchForText:(NSString *)searchText
{
    CoreDataStack *coreDataStack = [CoreDataStack defaultStack];
    if (coreDataStack.managedObjectContext)
    {
        NSString *predicateFormat = @"%K CONTAINS[cd] %@ or %K CONTAINS[cd] %@";
        NSString *searchAttribute = @"title";
        NSString *searchAttribute2 = @"text";
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat, searchAttribute, searchText, searchAttribute2, searchText];
        
        
        [self.searchFetchRequest setPredicate:predicate];
        
        NSError *error = nil;
        self.filteredList = [coreDataStack.managedObjectContext executeFetchRequest:self.searchFetchRequest error:&error];
    }
}


- (NSFetchRequest *)searchFetchRequest
{
    if (_searchFetchRequest != nil)
    {
        return _searchFetchRequest;
    }
    
    _searchFetchRequest = [[NSFetchRequest alloc] init];
    CoreDataStack *coreDataStack = [CoreDataStack defaultStack];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:coreDataStack.managedObjectContext];
    [_searchFetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    [_searchFetchRequest setSortDescriptors:sortDescriptors];
    
    return _searchFetchRequest;
}



#pragma mark - Notes Fetch Request

//twice?

-(NSFetchRequest *)noteListFetchRequest{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Note"];
    fetchRequest.sortDescriptors =@[[NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending:NO]];
    
    return fetchRequest;
}

-(NSFetchedResultsController *)fetchRequestController{
    if (_fetchRequestController != nil) {
        return _fetchRequestController;
    }
    CoreDataStack *coreDataStack = [CoreDataStack defaultStack];
    NSFetchRequest *fetchRequest = [self noteListFetchRequest];
    
    _fetchRequestController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:coreDataStack.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
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
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation: UITableViewRowAnimationAutomatic];
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
