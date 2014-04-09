//
//  SideTabViewController.m
//  Moobeez
//
//  Created by Radu Banea on 07/04/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "SideTabViewController.h"
#import "Moobeez.h"

@interface SideTabViewController ()

@property (strong, nonatomic) IBOutletCollection(UIViewController) NSArray *viewControllers;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *blurView;
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *buttonsView;

@property (readwrite, nonatomic) NSInteger selectedIndex;
@property (readonly, nonatomic) UIViewController* selectedViewController;

@property (weak, nonatomic) IBOutlet UILabel *notWatchedTeebeezLabel;
@property (readwrite, nonatomic) NSInteger notWatchedTeebeezCount;
@end

@implementation SideTabViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.selectedIndex = 0;
    
    self.blurView.alpha = 0.0;
    self.buttonsView.alpha = 0.0;
    
    [self.view addSubview:self.contentView];
    self.contentView.transform = CGAffineTransformMakeTranslation(self.contentView.width, 0);
    [UIView animateWithDuration:0.4 animations:^{
        self.contentView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [self.selectedViewController.view removeFromSuperview];
        self.appDelegate.window.rootViewController = self.selectedViewController;
    }];
    
    UISwipeGestureRecognizer* swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideMenu)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeGesture];
    
    self.notWatchedTeebeezLabel.layer.cornerRadius = 5;
    self.notWatchedTeebeezLabel.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.notWatchedTeebeezLabel.layer.borderWidth = 1;
    
    self.notWatchedTeebeezCount = [[Database sharedDatabase] notWatchedEpisodesCount];
    

}

- (UIViewController*)selectedViewController {
    return self.viewControllers[self.selectedIndex];
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    
    [self.selectedViewController.view removeFromSuperview];
    
    _selectedIndex = selectedIndex;
    
    self.selectedViewController.view.frame = self.contentView.bounds;
    [self.contentView addSubview:self.selectedViewController.view];
    
    [self setNeedsStatusBarAppearanceUpdate];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    if ([self.selectedViewController isKindOfClass:[UINavigationController class]]) {
        return ((UINavigationController*) self.selectedViewController).visibleViewController.preferredStatusBarStyle;
    }
    return self.selectedViewController.preferredStatusBarStyle;
}

- (void)showMenu {
    
    self.notWatchedTeebeezCount = [[Database sharedDatabase] notWatchedEpisodesCount];

    self.appDelegate.window.rootViewController = self.navigationController;
    [self.contentView addSubview:self.selectedViewController.view];
    
    self.blurView.alpha = 0.0;
    self.buttonsView.alpha = 0.0;
    
    [UIView animateWithDuration:0.4 animations:^{
        self.contentView.transform = CGAffineTransformMake(0.5, 0.0, 0.0, 0.5, self.view.width * 3 / 8, 0);
        self.blurView.alpha = 1.0;
        self.buttonsView.alpha = 1.0;
    }];
    
    self.contentView.userInteractionEnabled = NO;
    
}

- (void)hideMenu {

    [UIView animateWithDuration:0.4 animations:^{
        self.contentView.transform = CGAffineTransformIdentity;
        self.blurView.alpha = 0.0;
        self.buttonsView.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.contentView.userInteractionEnabled = YES;
        [self.selectedViewController.view removeFromSuperview];
        self.appDelegate.window.rootViewController = self.selectedViewController;
    }];

}

- (IBAction)blurViewTapped:(id)sender {
    [self hideMenu];
}

- (IBAction)menuButtonPressed:(id)sender {
    
    self.selectedIndex = ((UIButton*) sender).tag;
    [self hideMenu];
    
}

- (void)setNotWatchedTeebeezCount:(NSInteger)notWatchedTeebeezCount {
    
    _notWatchedTeebeezCount = notWatchedTeebeezCount;
    
    if (notWatchedTeebeezCount == 0) {
        self.notWatchedTeebeezLabel.hidden = YES;
        return;
    }
    
    self.notWatchedTeebeezLabel.hidden = NO;
    self.notWatchedTeebeezLabel.text = StringInteger(notWatchedTeebeezCount);
    CGSize size = [self.notWatchedTeebeezLabel sizeThatFits:self.notWatchedTeebeezLabel.frame.size];
    
    self.notWatchedTeebeezLabel.width = size.width + 13;
    
}

@end
