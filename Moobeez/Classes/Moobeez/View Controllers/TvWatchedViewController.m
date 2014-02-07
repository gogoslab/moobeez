//
//  TvWatchedViewController.m
//  Moobeez
//
//  Created by Radu Banea on 05/11/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "TvWatchedViewController.h"
#import "Moobeez.h"

@interface TvWatchedViewController ()

@property (weak, nonatomic) IBOutlet BubblePopupView *contentView;
@property (weak, nonatomic) IBOutlet UIView *navigationControllerContainerView;
@property (strong, nonatomic) IBOutlet UINavigationController *navigationController;
@property (weak, nonatomic) IBOutlet SeasonsViewController *seasonsViewController;

@end

@implementation TvWatchedViewController

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
    // Do any additional setup after loading the view from its nib.
    
    self.seasonsViewController.teebee = self.teebee;
    self.seasonsViewController.tv = self.tv;
    
    self.navigationController.view.frame = self.navigationControllerContainerView.bounds;
    [self.navigationControllerContainerView addSubview:self.navigationController.view];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startAnimation {

    CGPoint sourceCenter = [self.sourceButton.superview convertPoint:self.sourceButton.center toView:self.view];
    
    CGPoint bubbleSourceCenter = [self.contentView.sourceButton.superview convertPoint:self.contentView.sourceButton.center toView:self.view];
    
    self.contentView.sourceButton.x += sourceCenter.x - bubbleSourceCenter.x;
    self.contentView.sourceButton.y += sourceCenter.y - bubbleSourceCenter.y;

    self.navigationControllerContainerView.hidden = YES;
    
    [self.contentView startAnimation];
    
    self.contentView.animationCompletionHandler = ^{
        self.navigationControllerContainerView.hidden = NO;
    };
    
    [self.seasonsViewController reloadData];
}

#pragma mark - Back Button

- (IBAction)backButtonPressed:(id)sender {
    [self.view removeFromSuperview];
}


@end
