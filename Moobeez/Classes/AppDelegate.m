//
//  AppDelegate.m
//  Moobeez
//
//  Created by Radu Banea on 10/11/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "AppDelegate.h"
#import "Moobeez.h"
#import <FacebookSDK/FacebookSDK.h>
//#import <Crashlytics/Crashlytics.h>

void uncaughtExceptionHandler(NSException *exception);

void uncaughtExceptionHandler(NSException *exception) {
    
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
    // Internal error reporting
}

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
//    [Crashlytics startWithAPIKey:@"975fc7e2b44d8ca7ec8ff096827064b0c5c0facb"];

    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor mainColor],NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    
    [self.window makeKeyAndVisible];

    //init facebook framework
    [FBProfilePictureView class];
    
    [[NSFileManager defaultManager] removeItemAtPath:oldOfflineRootPath error:nil];
    
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
    [FBSession.activeSession handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark - load movies

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if ([[[url lastPathComponent] pathExtension] isEqualToString:@"moobeezbackup"]) {

        NSData* data = [NSData dataWithContentsOfURL:url];
        [data writeToFile:MY_MOVIES_PATH atomically:YES];
        [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
        
        [[Database sharedDatabase] replaceOldDatabase];
        
        return YES;
    }

    return [FBSession.activeSession handleOpenURL:url];
}


#pragma mark - Side Bar

- (SideTabViewController*)sideTabController {
    if (!_sideTabController) {
        _sideTabController = [[SideTabViewController alloc] initWithNibName:@"SideTabViewController" bundle:nil];
    }
    return _sideTabController;
}
@end

@implementation NSObject (AppDelegate)

- (AppDelegate*)appDelegate {
    return (AppDelegate*) [UIApplication sharedApplication].delegate;
}

@end
