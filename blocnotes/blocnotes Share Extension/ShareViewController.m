//
//  ShareViewController.m
//  blocnotes Share Extension
//
//  Created by Casey Ward on 6/14/15.
//  Copyright (c) 2015 Casey Ward. All rights reserved.
//

#import "ShareViewController.h"
#import "CoreDataStack.h"
#import "Note.h"

@interface ShareViewController ()

@end

@implementation ShareViewController

- (BOOL)isContentValid {
    // Do validation of contentText and/or NSExtensionContext attachments here
    return YES;
}

- (void)didSelectPost {
    // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.caseyward.blocnotes.extensionSharing"];
   
    [sharedDefaults setObject:self.contentText forKey:@"stringKey"];
    [sharedDefaults synchronize];
    
    // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
    [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
    
    CoreDataStack *coreDataStack = [CoreDataStack defaultStack];
    
    NSManagedObjectContext *context = [coreDataStack managedObjectContext];
    
    Note *newNote = [NSEntityDescription
                     insertNewObjectForEntityForName:@"Note"
                     inManagedObjectContext:context];
    newNote.text = self.contentText;
    newNote.title = self.contentText;
    newNote.timeStamp = [NSDate date];
    
    NSError *error;
    [context save:&error];
    
    
}

- (NSArray *)configurationItems {
    // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
    return @[];
}

@end
