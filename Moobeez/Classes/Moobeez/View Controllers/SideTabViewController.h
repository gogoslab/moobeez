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

@interface SideTabViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIView *contentView;

- (void)showMenu;
- (void)hideMenu;

@end
