//
//  CoreDataStack.m
//  blocnotes
//
//  Created by Casey Ward on 6/21/15.
//  Copyright (c) 2015 Casey Ward. All rights reserved.
//

#import "CoreDataStack.h"



@implementation CoreDataStack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

//iCloud
@synthesize modelURL = _modelURL;
@synthesize storeURL = _storeURL;

#pragma mark - instantiation

+(instancetype)defaultStack{
    static CoreDataStack *defaultStack;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultStack = [[self alloc] init];
    });
    
    return defaultStack;
}

//iCloud setup
/*
#pragma mark - iCloud setup

- (id)initWithStoreURL:(NSURL*)storeURL modelURL:(NSURL*)modelURL
{
    self = [super init];
    if (self) {
        self.storeURL = storeURL;
        self.modelURL = modelURL;
        [self setupManagedObjectContext];
    }
    return self;
}

- (void)setupManagedObjectContext
{
    self.managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    self.managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
    self.managedObjectContext.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    
    
    __weak NSPersistentStoreCoordinator *psc = self.managedObjectContext.persistentStoreCoordinator;
    
    // iCloud notification subscriptions
    NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];
    [dc addObserver:self
           selector:@selector(storesWillChange:)
               name:NSPersistentStoreCoordinatorStoresWillChangeNotification
             object:psc];
    
    [dc addObserver:self
           selector:@selector(storesDidChange:)
               name:NSPersistentStoreCoordinatorStoresDidChangeNotification
             object:psc];
    
    [dc addObserver:self
           selector:@selector(persistentStoreDidImportUbiquitousContentChanges:)
               name:NSPersistentStoreDidImportUbiquitousContentChangesNotification
             object:psc];
    
    NSError* error;
    // the only difference in this call that makes the store an iCloud enabled store
    // is the NSPersistentStoreUbiquitousContentNameKey in options. I use "iCloudStore"
    // but you can use what you like. For a non-iCloud enabled store, I pass "nil" for options.
    
    // Note that the store URL is the same regardless of whether you're using iCloud or not.
    // If you create a non-iCloud enabled store, it will be created in the App's Documents directory.
    // An iCloud enabled store will be created below a directory called CoreDataUbiquitySupport
    // in your App's Documents directory
    [self.managedObjectContext.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                                       configuration:nil
                                                                                 URL:self.storeURL
                                                                             options:@{ NSPersistentStoreUbiquitousContentNameKey : @"iCloudStore" }
                                                                               error:&error];
    if (error) {
        NSLog(@"error: %@", error);
    }
}

- (NSManagedObjectModel*)managedObjectModel
{
    return [[NSManagedObjectModel alloc] initWithContentsOfURL:self.modelURL];
}

// Subscribe to NSPersistentStoreDidImportUbiquitousContentChangesNotification
*/

- (void)persistentStoreDidImportUbiquitousContentChanges:(NSNotification*)note
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"%@", note.userInfo.description);
    
    NSManagedObjectContext *moc = self.managedObjectContext;
    [moc performBlock:^{
        [moc mergeChangesFromContextDidSaveNotification:note];
        
        // you may want to post a notification here so that which ever part of your app
        // needs to can react appropriately to what was merged.
        // An exmaple of how to iterate over what was merged follows, although I wouldn't
        // recommend doing it here. Better handle it in a delegate or use notifications.
        // Note that the notification contains NSManagedObjectIDs
        // and not NSManagedObjects.
        NSDictionary *changes = note.userInfo;
        NSMutableSet *allChanges = [NSMutableSet new];
        [allChanges unionSet:changes[NSInsertedObjectsKey]];
        [allChanges unionSet:changes[NSUpdatedObjectsKey]];
        [allChanges unionSet:changes[NSDeletedObjectsKey]];
        
        for (NSManagedObjectID *objID in allChanges) {
            // do whatever you need to with the NSManagedObjectID
            // you can retrieve the object from with [moc objectWithID:objID]
        }
        
    }];
}

// Subscribe to NSPersistentStoreCoordinatorStoresWillChangeNotification
// most likely to be called if the user enables / disables iCloud
// (either globally, or just for your app) or if the user changes
// iCloud accounts.
- (void)storesWillChange:(NSNotification *)note {
    NSManagedObjectContext *moc = self.managedObjectContext;
    [moc performBlockAndWait:^{
        NSError *error = nil;
        if ([moc hasChanges]) {
            [moc save:&error];
        }
        
        [moc reset];
    }];
    
    // now reset your UI to be prepared for a totally different
    // set of data (eg, popToRootViewControllerAnimated:)
    // but don't load any new data yet.
}

// Subscribe to NSPersistentStoreCoordinatorStoresDidChangeNotification
- (void)storesDidChange:(NSNotification *)note {
    // here is when you can refresh your UI and
    // load new data from the new store
}



//CoreData setup
#pragma mark - Core Data setup


- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.caseyward.blocnotes.blocnotes" in the application's documents directory.
    return [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.caseyward.blocnotes"];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    //
    
    self.storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"blocnotes.sqlite"];

    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"blocnotes" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    self.managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
    self.managedObjectContext.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    
    
    __weak NSPersistentStoreCoordinator *psc = self.managedObjectContext.persistentStoreCoordinator;
    
    // iCloud notification subscriptions
    NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];
    [dc addObserver:self
           selector:@selector(storesWillChange:)
               name:NSPersistentStoreCoordinatorStoresWillChangeNotification
             object:psc];
    
    [dc addObserver:self
           selector:@selector(storesDidChange:)
               name:NSPersistentStoreCoordinatorStoresDidChangeNotification
             object:psc];
    
    [dc addObserver:self
           selector:@selector(persistentStoreDidImportUbiquitousContentChanges:)
               name:NSPersistentStoreDidImportUbiquitousContentChangesNotification
             object:psc];
    
    NSError* error;
    // the only difference in this call that makes the store an iCloud enabled store
    // is the NSPersistentStoreUbiquitousContentNameKey in options. I use "iCloudStore"
    // but you can use what you like. For a non-iCloud enabled store, I pass "nil" for options.
    
    // Note that the store URL is the same regardless of whether you're using iCloud or not.
    // If you create a non-iCloud enabled store, it will be created in the App's Documents directory.
    // An iCloud enabled store will be created below a directory called CoreDataUbiquitySupport
    // in your App's Documents directory
    [self.managedObjectContext.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                                       configuration:nil
                                                                                 URL:self.storeURL
                                                                             options:@{ NSPersistentStoreUbiquitousContentNameKey : @"iCloud.com.caseyward.blocnotes" }
                                                                               error:&error];
    if (error) {
        NSLog(@"error: %@", error);
    }

    //
    
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:self.storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

@end
