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
@property (weak, nonatomic) IBOutlet UIButton *checkinShowButton;

@property (nonatomic) NSString *shortcutToPerform;

@end

@implementation SideTabViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.selectedIndex = 5;
    
    self.blurView.alpha = 0.0;
    self.buttonsView.alpha = 0.0;
    self.checkinButton.alpha = 0.0;
    self.checkinShowButton.alpha = 0.0;
    
    [self.view addSubview:self.contentView];
    
    if (self.shortcutToPerform == nil)
    {
        self.contentView.transform = CGAffineTransformMakeTranslation(self.contentView.width, 0);
        [UIView animateWithDuration:0.4 animations:^{
            self.contentView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [self.selectedViewController.view removeFromSuperview];
            self.appDelegate.window.rootViewController = self.selectedViewController;
        }];
    }
    
    UISwipeGestureRecognizer* swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideMenu)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeGesture];
    
    self.notWatchedTeebeezLabel.layer.cornerRadius = 5;
    self.notWatchedTeebeezLabel.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.notWatchedTeebeezLabel.layer.borderWidth = 1;
    
    self.notWatchedTeebeezCount = [[Database sharedDatabase] notWatchedEpisodesCount];
    
    self.searchBar.alpha = 0.0;

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.shortcutToPerform != nil)
    {
        [self performShortcut:self.shortcutToPerform];
        self.shortcutToPerform = nil;
    }
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

- (void)showMenu
{
    [self showMenuAnimated:YES];
}

- (void)showMenuAnimated:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SideTabMenuWillAppearNotification object:nil];
    
    self.notWatchedTeebeezCount = [[Database sharedDatabase] notWatchedEpisodesCount];

    self.appDelegate.window.rootViewController = self.navigationController;
    [self.contentView addSubview:self.selectedViewController.view];
    
    self.blurView.alpha = 0.0;
    self.buttonsView.alpha = 0.0;
    
    [UIView animateWithDuration:(animated ? 0.4 : 0.0) animations:^{
        self.contentView.transform = CGAffineTransformMake(0.5, 0.0, 0.0, 0.5, self.view.width * 3 / 8, self.buttonsView.center.y - self.view.height / 2);
        self.blurView.alpha = 1.0;
    }];

    [UIView animateWithDuration:(animated ? 0.2 : 0.0) delay:(animated ? 0.2 : 0.0) options:UIViewAnimationOptionTransitionNone animations:^{
        self.buttonsView.alpha = 1.0;
        self.checkinButton.alpha = 1.0;
        self.checkinShowButton.alpha = 1.0;
        self.searchBar.alpha = 1.0;
    } completion:^(BOOL finished) {
        
    }];

    self.contentView.userInteractionEnabled = NO;
    
}

- (void)hideMenu
{
    [self hideMenuAnimated:YES];
}

- (void)hideMenuAnimated:(BOOL)animated {

    [[NSNotificationCenter defaultCenter] postNotificationName:SideTabMenuWillDisappearNotification object:nil];

    [UIView animateWithDuration:(animated ? 0.2 : 0.0) delay:0.0 options:UIViewAnimationOptionTransitionNone animations:^{
        self.buttonsView.alpha = 0.0;
        self.checkinButton.alpha = 0.0;
        self.checkinShowButton.alpha = 0.0;
        self.searchBar.alpha = 0.0;
    } completion:^(BOOL finished) {}];
    

    [UIView animateWithDuration:(animated ? 0.4 : 0.0)  animations:^{
        self.contentView.transform = CGAffineTransformIdentity;
        self.blurView.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.contentView.userInteractionEnabled = YES;
        if (self.selectedViewController.view.superview == self.contentView)
        {
            [self.selectedViewController.view removeFromSuperview];
        }
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

- (IBAction)checkinTvShowButtonPressed:(id)sender {
    [self presentViewController:self.checkinShowNavigationViewController animated:YES completion:^{
        
    }];
}

- (void)setNotWatchedTeebeezCount:(NSInteger)notWatchedTeebeezCount {
    
    _notWatchedTeebeezCount = notWatchedTeebeezCount;
    
    if (notWatchedTeebeezCount == 0) {
        self.notWatchedTeebeezLabel.hidden = YES;
        return;
    }
    
    self.notWatchedTeebeezLabel.hidden = NO;
    self.notWatchedTeebeezLabel.text = StringInteger((long)notWatchedTeebeezCount);
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
        searchBar.width = self.view.width - 16;
    }];
    
    [searchBar resignFirstResponder];
    
    [searchBar setShowsCancelButton:NO animated:YES];

    [self.searchNavigationViewController dismissViewControllerAnimated:YES completion:^{
        [self.view insertSubview:searchBar belowSubview:self.contentView];
    }];
}

- (void)presentCheckInViewControllerAnimated:(BOOL)animated {
    
    [self showMenuAnimated:animated];
    
    [self presentViewController:self.checkinNavigationViewController animated:animated completion:^{
        
    }];
    
}

- (void)presentCheckInTvShowViewControllerAnimated:(BOOL)animated {
    
    [self showMenuAnimated:animated];
    
    [self presentViewController:self.checkinShowNavigationViewController animated:animated completion:^{
        
    }];
    
}

- (void)performShortcut:(NSString *)shortcut
{
    if (self.navigationController == nil)
    {
        self.shortcutToPerform = shortcut;
        return;
    }
    
    NSArray *components = [shortcut componentsSeparatedByString:@"."];
    
    NSString *action = components[0];
    NSString *type = components[1];
    
    if ([action isEqualToString:@"add"])
    {
        NSInteger goToIndex = -1;
        
        if ([type isEqualToString:@"movie"])
        {
            goToIndex = 0;
        }
        else if ([type isEqualToString:@"tvshow"])
        {
            goToIndex = 2;
        }
        
        if (goToIndex >= 0)
        {
            if (self.presentedViewController != nil)
            {
                [self.presentedViewController dismissViewControllerAnimated:NO completion:nil];
            }
            
            if (self.selectedIndex != goToIndex)
            {
                self.selectedIndex = goToIndex;
            }
            [self hideMenuAnimated:NO];
            
            UINavigationController* navigationController = (UINavigationController*) self.selectedViewController;
            
            navigationController.viewControllers = @[navigationController.viewControllers.firstObject];
            
            [navigationController.viewControllers.firstObject performSelector:@selector(addButtonPressed:) withObject:nil afterDelay:0.2];
            
        }
    }
    else if ([action isEqualToString:@"checkin"])
    {
        if ([type isEqualToString:@"movie"])
        {
            if (self.presentedViewController != nil)
            {
                [self.presentedViewController dismissViewControllerAnimated:NO completion:nil];
            }
            [self presentCheckInViewControllerAnimated:NO];
        }
        else if ([type isEqualToString:@"tvshow"])
        {
            if (self.presentedViewController != nil)
            {
                [self.presentedViewController dismissViewControllerAnimated:NO completion:nil];
            }
            
            [self presentCheckInTvShowViewControllerAnimated:NO];
        }
    }

}


@end

