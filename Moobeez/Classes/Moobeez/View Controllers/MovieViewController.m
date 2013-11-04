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

@property (weak, nonatomic) IBOutlet UIButton *addButton;


@property (strong, nonatomic) TextViewController* descriptionViewController;

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
    
    self.addButton.hidden = (self.moobee.id != -1);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonPressed:(id)sender {
    
    [self dismissViewControllerAnimated:NO completion:^{
        if (self.moobee.id != -1) {
            [self.moobee save];
        }
        self.closeHandler();
    }];
}

- (IBAction)shareButtonPressed:(id)sender {
}

- (IBAction)addButtonPressed:(id)sender {
    if([self.moobee save]) {
        self.addButton.hidden = YES;
    }
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


#pragma mark - Description

- (IBAction)descriptionButtonPressed:(id)sender {
    
    self.descriptionViewController.text = self.tmdbMovie.description;
    [self.appDelegate.window addSubview:self.descriptionViewController.view];
}

- (TextViewController*)descriptionViewController {
    if (!_descriptionViewController) {
        _descriptionViewController = [[TextViewController alloc] initWithNibName:@"TextViewController" bundle:nil];
        _descriptionViewController.view.frame = self.appDelegate.window.bounds;
    }
    return _descriptionViewController;
}


- (IBAction)castButtonPressed:(id)sender {
}

- (IBAction)photosButtonPressed:(id)sender {
}

- (IBAction)trailerButtonPressed:(id)sender {
}

@end
