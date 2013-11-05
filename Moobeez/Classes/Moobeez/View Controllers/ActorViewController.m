//
//  MovieViewController.m
//  Moobeez
//
//  Created by Radu Banea on 11/05/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "ActorViewController.h"
#import "Moobeez.h"

@interface ActorViewController () <UITextFieldDelegate, ToolboxViewDelegate>

@property (weak, nonatomic) IBOutlet ImageView *posterImageView;

@property (strong, nonatomic) IBOutlet ActorToolboxView *toolboxView;

@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *hideToolboxRecognizer;

@property (strong, nonatomic) TextViewController* descriptionViewController;
@property (strong, nonatomic) CastViewController* castViewController;

@end

@implementation ActorViewController

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
    
    [self.posterImageView loadImageWithPath:self.tmdbActor.profilePath andWidth:185 completion:^(BOOL didLoadImage) {
        [self.toolboxView addToSuperview:self.view];
        self.toolboxView.tmdbPerson = self.tmdbActor;
        self.toolboxView.characterSelectionHandler = ^(TmdbCharacter* tmdbCharacter) {
            if (tmdbCharacter.movie) {
                [self openMovie:tmdbCharacter.movie];
            }
        };

        self.posterImageView.defaultImage = self.posterImageView.image;
        [self.posterImageView loadImageWithPath:self.tmdbActor.profilePath andHeight:632 completion:^(BOOL didLoadImage) {
        }];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonPressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{}];
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
    
    [self.view addSubview:self.descriptionViewController.view];
    self.descriptionViewController.sourceButton = sender;
    self.descriptionViewController.text = self.tmdbActor.description;
    [self.descriptionViewController startAnimation];
}

- (TextViewController*)descriptionViewController {
    if (!_descriptionViewController) {
        _descriptionViewController = [[TextViewController alloc] initWithNibName:@"TextViewController" bundle:nil];
        _descriptionViewController.view.frame = self.view.bounds;
    }
    return _descriptionViewController;
}

#pragma mark - Cast

- (IBAction)castButtonPressed:(id)sender {
    [self.view addSubview:self.castViewController.view];
    self.castViewController.sourceButton = sender;
    self.castViewController.castArray = self.tmdbActor.characters;
    [self.castViewController startAnimation];
    
    self.castViewController.characterSelectionHandler = ^(TmdbCharacter* tmdbCharacter) {
        if (tmdbCharacter.movie) {
            [self openMovie:tmdbCharacter.movie];
        }
    };
}

- (CastViewController*)castViewController {
    if (!_castViewController) {
        _castViewController = [[CastViewController alloc] initWithNibName:@"CastViewController" bundle:nil];
        _castViewController.view.frame = self.view.bounds;
    }
    return _castViewController;
}

- (void)openMovie:(TmdbMovie*)movie {
    
    Moobee* moobee = [Moobee moobeeWithTmdbMovie:movie];
    
    if (moobee.id == -1) {
        moobee.type = MoobeeNoneType;
    }
    
    self.view.userInteractionEnabled = NO;
    MovieConnection* connection = [[MovieConnection alloc] initWithTmdbId:moobee.tmdbId completionHandler:^(WebserviceResultCode code, TmdbMovie *movie) {
        MovieViewController* viewController = [[MovieViewController alloc] initWithNibName:@"MovieViewController" bundle:nil];
        viewController.moobee = moobee;
        viewController.tmdbMovie = movie;
        [self presentViewController:viewController animated:NO completion:^{}];

    }];
    [self startConnection:connection];

}

- (IBAction)photosButtonPressed:(id)sender {
}

- (IBAction)trailerButtonPressed:(id)sender {
}

@end
