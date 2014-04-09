//
//  NavigationController.m
//  Moobeez
//
//  Created by Radu Banea on 07/11/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "NavigationController.h"
#import "Moobeez.h"

@interface NavigationController ()

@end

@implementation NavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.topViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu_button.png"] style:UIBarButtonItemStylePlain target:self.appDelegate.sideTabController action:@selector(showMenu)];
    self.topViewController.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    
    UISwipeGestureRecognizer* swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self.appDelegate.sideTabController action:@selector(showMenu)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self.topViewController.view addGestureRecognizer:swipeGesture];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
