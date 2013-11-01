//
//  MovieViewController.m
//  Moobeez
//
//  Created by Radu Banea on 10/21/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "MovieViewController.h"
#import "Moobeez.h"

@interface MovieViewController () <UITextFieldDelegate, ToolboxViewDelegate>

@property (weak, nonatomic) IBOutlet ImageView *posterImageView;

@property (strong, nonatomic) IBOutlet MovieToolboxView *toolboxView;

@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *hideToolboxRecognizer;
@end

@implementation MovieViewController

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
    
    [self.posterImageView loadImageWithPath:self.moobee.posterPath andWidth:154 completion:^(BOOL didLoadImage) {
        self.posterImageView.defaultImage = self.posterImageView.image;
        [self.posterImageView loadImageWithPath:self.moobee.posterPath andWidth:500 completion:^(BOOL didLoadImage) {}];
    }];
    
    [self.toolboxView addToSuperview:self.view];

    self.toolboxView.moobee = self.moobee;
    self.toolboxView.tmdbMovie = self.tmdbMovie;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonPressed:(id)sender {
    
    [self dismissViewControllerAnimated:NO completion:^{
        self.closeHandler();
    }];
}

- (IBAction)shareButtonPressed:(id)sender {
}

- (IBAction)hideToolbox:(id)sender {
    [self.toolboxView hideFullToolbox];
}

- (void)toolboxViewDidShow:(ToolboxView *)toolboxView {
    [self.posterImageView addGestureRecognizer:self.hideToolboxRecognizer];
}

- (void)toolboxViewWillHide:(ToolboxView *)toolboxView {
    [self.posterImageView removeGestureRecognizer:self.hideToolboxRecognizer];
}

@end
