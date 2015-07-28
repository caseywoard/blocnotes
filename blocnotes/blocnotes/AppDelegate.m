//
//  AppDelegate.m
//  blocnotes
//
//  Created by Casey Ward on 5/18/15.
//  Copyright (c) 2015 Casey Ward. All rights reserved.
//

#import "AppDelegate.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self setupAppearance];
    NSLog(@"hello world");
    //iCloud
   
    /*
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    id currentiCloudToken = fileManager.ubiquityIdentityToken;
    
    if (currentiCloudToken) {
        NSData *newTokenData = [NSKeyedArchiver archivedDataWithRootObject: currentiCloudToken];
        [[NSUserDefaults standardUserDefaults] setObject: newTokenData
                                                  forKey: @"com.caseyward.blocnotes.blocnotes.UbiquityIdentityToken"];
        } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey: @"com.caseyward.blocnotes.blocnotes.UbiquityIdentityToken"];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector (ubiquitousKeyValueStoreDidChange:)
                                                 name: NSUbiquityIdentityDidChangeNotification
                                               object: nil];
    
   
    
    if (currentiCloudToken && firstLaunchWithiCloudAvailable) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Choose Storage Option"
                                                        message: @"Should documents be stored in iCloud and available on all your devices?"
                                                       delegate: self
                                              cancelButtonTitle: @"Local Only"
                                              otherButtonTitles: @"Use iCloud", nil];
        
        [alert show];
        
    }
    */
    
    //
    
    return YES;
}

- (void)ubiquitousKeyValueStoreDidChange:(NSNotification*)notification {
    NSUbiquitousKeyValueStore *ubiquitousKeyValueStore = notification.object;
    [ubiquitousKeyValueStore synchronize];
}

-(void)setupAppearance {
    UINavigationBar *navigationBarAppearance = [UINavigationBar appearance];
    navigationBarAppearance.barTintColor = [UIColor colorWithRed:77.0/255.0 green:164.0/255.0 blue:191.0/255.0 alpha:1.0f];
    navigationBarAppearance.tintColor = [UIColor whiteColor];
    navigationBarAppearance.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    
}




@end
