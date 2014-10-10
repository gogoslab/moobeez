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
    
    CGSize size = [MoviePosterView size];
    
    [self.posterImageView loadProfileWithPath:self.tmdbActor.profilePath size:size completion:^(BOOL didLoadImage) {
        self.toolboxView.width = self.view.width;
        [self.toolboxView addToSuperview:self.view];
        self.toolboxView.tmdbPerson = self.tmdbActor;
        self.toolboxView.characterSelectionHandler = ^(TmdbCharacter* tmdbCharacter, CharacterCell* cell) {
            if (tmdbCharacter.movie) {
                [self openMovie:tmdbCharacter.movie fromCharacterCell:cell];
            }
        };

        self.posterImageView.defaultImage = self.posterImageView.image;
        [self.posterImageView loadProfileWithPath:self.tmdbActor.profilePath completion:^(BOOL didLoadImage) {
        }];
        
        [self.toolboxView performSelector:@selector(showFullToolbox) withObject:nil afterDelay:0.5];

    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonPressed:(id)sender {
    
    if (self.closeHandler) {
        self.closeHandler();
    }

    [self.navigationController popViewControllerAnimated:NO];
    
    self.closeHandler = nil;
    self.toolboxView.characterSelectionHandler = nil;
    self.castViewController.characterSelectionHandler = nil;

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
    self.descriptionViewController.text = self.tmdbActor.overview;
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
    
    self.castViewController.characterSelectionHandler = ^(TmdbCharacter* tmdbCharacter, CharacterTableCell* cell) {
        if (tmdbCharacter.movie) {
            [self openMovie:tmdbCharacter.movie fromCharacterTableCell:cell];
        }
    };
}

- (CastViewController*)castViewController {
    if (!_castViewController) {
        _castViewController = [[CastViewController alloc] initWithNibName:@"CastViewController" bundle:nil];
        _castViewController.areMovies = YES;
        _castViewController.view.frame = self.view.bounds;
    }
    return _castViewController;
}

- (void)openMovie:(TmdbMovie*)movie fromCharacterTableCell:(CharacterTableCell*)cell {
    
    Moobee* moobee = [Moobee moobeeWithTmdbMovie:movie];
    
    if (moobee.id == -1) {
        moobee.type = MoobeeNoneType;
    }
    
    self.view.userInteractionEnabled = NO;
    MovieConnection* connection = [[MovieConnection alloc] initWithTmdbId:moobee.tmdbId completionHandler:^(WebserviceResultCode code, TmdbMovie *movie) {
        
        if (code == WebserviceResultOk) {
            [cell animateGrowWithCompletion:^{
                MovieViewController* viewController = [[MovieViewController alloc] initWithNibName:@"MovieViewController" bundle:nil];
                viewController.moobee = moobee;
                viewController.tmdbMovie = movie;
                
                moobee.posterPath = movie.posterPath;
                moobee.backdropPath = movie.backdropPath;
                moobee.releaseDate = movie.releaseDate;

                
                viewController.closeHandler = ^{
                    [cell animateShrinkWithCompletion:^{
                        self.view.userInteractionEnabled = YES;
                    }];
                };
                
                [self.navigationController pushViewController:viewController animated:NO];
            }];
        }
    }];
    connection.activityIndicator = cell.activityIndicator;
    [self.connectionsManager startConnection:connection];
    
}


- (void)openMovie:(TmdbMovie*)movie fromCharacterCell:(CharacterCell*)cell {
    
    Moobee* moobee = [Moobee moobeeWithTmdbMovie:movie];
    
    if (moobee.id == -1) {
        moobee.type = MoobeeNoneType;
    }
    
    self.view.userInteractionEnabled = NO;
    MovieConnection* connection = [[MovieConnection alloc] initWithTmdbId:moobee.tmdbId completionHandler:^(WebserviceResultCode code, TmdbMovie *movie) {
        if (code == WebserviceResultOk) {
            [cell animateGrowWithCompletion:^{
                MovieViewController* viewController = [[MovieViewController alloc] initWithNibName:@"MovieViewController" bundle:nil];
                viewController.moobee = moobee;
                viewController.tmdbMovie = movie;
                
                moobee.posterPath = movie.posterPath;
                moobee.backdropPath = movie.backdropPath;
                moobee.releaseDate = movie.releaseDate;
                
                viewController.closeHandler = ^{
                    [cell animateShrinkWithCompletion:^{
                        self.view.userInteractionEnabled = YES;
                    }];
                };
                
                [self.navigationController pushViewController:viewController animated:NO];
            }];
        }
    }];
    connection.activityIndicator = cell.activityIndicator;
    [self.connectionsManager startConnection:connection];
    
}

- (IBAction)photosButtonPressed:(id)sender {
    
    ImagesViewController* viewController = [[ImagesViewController alloc] initWithNibName:@"ImagesViewController" bundle:nil];
    viewController.images = self.tmdbActor.profileImages;
    viewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:viewController animated:YES completion:^{}];
    
}


@end
