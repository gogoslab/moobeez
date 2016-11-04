//
//  AppDelegate.h
//  Moobeez
//
//  Created by Radu Banea on 10/11/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SideTabViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) IBOutlet UIWindow *window;

@property (strong, nonatomic) SideTabViewController *sideTabController;

@end

@interface NSObject (AppDelegate)

@property (readonly, nonatomic) AppDelegate* appDelegate;

@end