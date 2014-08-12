//
//  SideTabViewController.h
//  Moobeez
//
//  Created by Radu Banea on 07/04/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SideTabMenuWillAppearNotification @"SideTabMenuWillAppear"
#define SideTabMenuWillDisappearNotification @"SideTabMenuWillDisappear"

@class NavigationController;

@interface SideTabSearchBar : UISearchBar

@end

@interface SideTabViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIView *contentView;

@property (strong, nonatomic) IBOutlet NavigationController *checkinNavigationViewController;

- (void)showMenu;
- (void)hideMenu;

- (void)presentCheckInViewController;

@end
