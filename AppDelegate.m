//
//  AppDelegate.m
//  tryngo
//
//  Created by michail on 13/03/15.
//  Copyright (c) 2015 Rhinoda. All rights reserved.
//

#import "AppDelegate.h"
#import "UserDataSingleton.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    UIDevice *currentDevice = [UIDevice currentDevice];
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        [UserDataSingleton sharedSingleton].Sufix = @"-iphone";
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        [UserDataSingleton sharedSingleton].Sufix = @"-ipad";
    }
    [UserDataSingleton sharedSingleton].offerImagePrefix = @"https://www.tryngo.ch/uploads/objects/";
    [UserDataSingleton sharedSingleton].thumbImagePrefix = @"https://www.tryngo.ch/timthumb.php?src=https://www.tryngo.ch/uploads/objects";
    [UserDataSingleton sharedSingleton].userImagePrefix = @"https://www.tryngo.ch/timthumb.php?src=https://www.tryngo.ch/uploads/users/thumb/";
    
    OfferViewController *offerViewController = [[OfferViewController alloc] init];
    self.window.rootViewController = offerViewController;
    return YES;
}

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

@end
