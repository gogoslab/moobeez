//
//  SideTabViewController.m
//  Moobeez
//
//  Created by Radu Banea on 07/04/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "SideTabViewController.h"
#import "Moobeez.h"

@implementation SideTabSearchBar

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [[UITextField appearanceWhenContainedIn:[SideTabSearchBar class], nil] setTextColor:[UIColor whiteColor]];
        
        [[UIBarButtonItem appearanceWhenContainedIn:[SideTabSearchBar class], nil] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]} forState:UIControlStateNormal];
        
        [self setImage:[UIImage imageNamed:@"search_bar_icon.png"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
        [self setImage:[UIImage imageNamed:@"search_bar_clear_icon.png"] forSearchBarIcon:UISearchBarIconClear state:UIControlStateNormal];
        [self setImage:[UIImage imageNamed:@"search_bar_clear_icon_highlighted.png"] forSearchBarIcon:UISearchBarIconClear state:UIControlStateHighlighted];
        
    }
    
    
    return self;
}

@end

@interface SideTabViewController () <UISearchBarDelegate>

@property (strong, nonatomic) IBOutletCollection(UIViewController) NSArray *viewControllers;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *blurView;
@property (weak, nonatomic) IBOutlet UIView *buttonsView;

@property (readwrite, nonatomic) NSInteger selectedIndex;
@property (readonly, nonatomic) UIViewController* selectedViewController;

@property (strong, nonatomic) IBOutlet NavigationController *searchNavigationViewController;
@property (weak, nonatomic) IBOutlet SearchViewController *searchViewController;

@property (weak, nonatomic) IBOutlet SideTabSearchBar *searchBar;

@property (weak, nonatomic) IBOutlet UILabel *notWatchedTeebeezLabel;
@property (readwrite, nonatomic) NSInteger notWatchedTeebeezCount;

@property (weak, nonatomic) IBOutlet UIButton *checkinButton;
@end

@implementation SideTabViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.selectedIndex = 4;
    
    self.blurView.alpha = 0.0;
    self.buttonsView.alpha = 0.0;
    self.checkinButton.alpha = 0.0;
    
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
    
    self.searchBar.alpha = 0.0;

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
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SideTabMenuWillAppearNotification object:nil];
    
    self.notWatchedTeebeezCount = [[Database sharedDatabase] notWatchedEpisodesCount];

    self.appDelegate.window.rootViewController = self.navigationController;
    [self.contentView addSubview:self.selectedViewController.view];
    
    self.blurView.alpha = 0.0;
    self.buttonsView.alpha = 0.0;
    
    [UIView animateWithDuration:0.4 animations:^{
        self.contentView.transform = CGAffineTransformMake(0.5, 0.0, 0.0, 0.5, self.view.width * 3 / 8, 0);
        self.blurView.alpha = 1.0;
    }];

    [UIView animateWithDuration:0.2 delay:0.2 options:UIViewAnimationOptionTransitionNone animations:^{
        self.buttonsView.alpha = 1.0;
        self.checkinButton.alpha = 1.0;
        self.searchBar.alpha = 1.0;
    } completion:^(BOOL finished) {
        
    }];

    self.contentView.userInteractionEnabled = NO;
    
}

- (void)hideMenu {

    [[NSNotificationCenter defaultCenter] postNotificationName:SideTabMenuWillDisappearNotification object:nil];

    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionTransitionNone animations:^{
        self.buttonsView.alpha = 0.0;
        self.checkinButton.alpha = 0.0;
        self.searchBar.alpha = 0.0;
    } completion:^(BOOL finished) {}];
    

    [UIView animateWithDuration:0.4 animations:^{
        self.contentView.transform = CGAffineTransformIdentity;
        self.blurView.alpha = 0.0;
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

- (IBAction)checkinButtonPressed:(id)sender {
    [self presentViewController:self.checkinNavigationViewController animated:YES completion:^{
        
    }];
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

#pragma mark - Search

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [searchBar resignFirstResponder];
    
    if (!self.searchNavigationViewController.presentingViewController) {
        [self.appDelegate.window addSubview:searchBar];
        [searchBar setShowsCancelButton:YES animated:YES];
        [self presentViewController:self.searchNavigationViewController animated:YES completion:^{
        }];
        
        [self.searchNavigationViewController removeSideAction];
    }
    else {
        [self.searchViewController performSearch];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {

    self.searchBar.frame = [self.appDelegate.window convertRect:self.searchBar.frame fromView:self.searchBar.superview];
    [self.appDelegate.window addSubview:self.searchBar];

    [UIView animateWithDuration:0.3 animations:^{
        searchBar.width = 304;
    }];
    
    [searchBar resignFirstResponder];
    
    [searchBar setShowsCancelButton:NO animated:YES];

    [self.searchNavigationViewController dismissViewControllerAnimated:YES completion:^{
        [self.view insertSubview:searchBar belowSubview:self.contentView];
    }];
}

- (void)presentCheckInViewController {
    
    [self showMenu];
    
    [self presentViewController:self.checkinNavigationViewController animated:YES completion:^{
        
    }];
    
}

@end

