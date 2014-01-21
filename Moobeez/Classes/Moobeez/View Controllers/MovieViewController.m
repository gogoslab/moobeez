//
//  MovieViewController.m
//  Moobeez
//
//  Created by Radu Banea on 10/21/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "MovieViewController.h"
#import "Moobeez.h"

#import <MediaPlayer/MediaPlayer.h>

@interface MovieViewController () <UITextFieldDelegate, ToolboxViewDelegate>

@property (weak, nonatomic) IBOutlet ImageView *posterImageView;

@property (strong, nonatomic) IBOutlet MovieToolboxView *toolboxView;

@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *hideToolboxRecognizer;

@property (weak, nonatomic) IBOutlet UIButton *addButton;


@property (strong, nonatomic) TextViewController* descriptionViewController;
@property (strong, nonatomic) CastViewController* castViewController;

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
        
        [self.toolboxView addToSuperview:self.view];
        self.toolboxView.moobee = self.moobee;
        self.toolboxView.tmdbMovie = self.tmdbMovie;

        self.toolboxView.characterSelectionHandler = ^(TmdbCharacter* tmdbCharacter, CharacterCell* cell) {
            if (tmdbCharacter.person) {
                [self openPerson:tmdbCharacter.person fromCharacterCell:cell];
            }
        };

        self.posterImageView.defaultImage = self.posterImageView.image;
        
        [self.posterImageView loadImageWithPath:self.moobee.posterPath andWidth:500 completion:^(BOOL didLoadImage) {
          
        }];
        
        [self.toolboxView performSelector:@selector(showFullToolbox) withObject:nil afterDelay:0.5];
    }];
    
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
        if (self.closeHandler) {
            self.closeHandler();
        }
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
    
    [self.view addSubview:self.descriptionViewController.view];
    self.descriptionViewController.sourceButton = sender;
    self.descriptionViewController.text = self.tmdbMovie.description;
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
    self.castViewController.castArray = self.tmdbMovie.characters;
    [self.castViewController startAnimation];
    
    self.castViewController.characterSelectionHandler = ^(TmdbCharacter* tmdbCharacter, CharacterTableCell* cell) {
        if (tmdbCharacter.person) {
            [self openPerson:tmdbCharacter.person fromCharacterTableCell:cell];
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

- (void)openPerson:(TmdbPerson*)person fromCharacterTableCell:(CharacterTableCell*)cell {
    PersonConnection* connection = [[PersonConnection alloc] initWithTmdbId:person.id completionHandler:^(WebserviceResultCode code, TmdbPerson *person) {
        [cell animateGrowWithCompletion:^{
            ActorViewController* viewController = [[ActorViewController alloc] initWithNibName:@"ActorViewController" bundle:nil];
            viewController.tmdbActor = person;
            viewController.closeHandler = ^{
                [cell animateShrinkWithCompletion:^{}];
            };
            [self presentViewController:viewController animated:NO completion:^{}];
        }];
    }];
    
    connection.activityIndicator = cell.activityIndicator;
    [self.connectionsManager startConnection:connection];
}

- (void)openPerson:(TmdbPerson*)person fromCharacterCell:(CharacterCell*)cell {
    PersonConnection* connection = [[PersonConnection alloc] initWithTmdbId:person.id completionHandler:^(WebserviceResultCode code, TmdbPerson *person) {
        [cell animateGrowWithCompletion:^{
            ActorViewController* viewController = [[ActorViewController alloc] initWithNibName:@"ActorViewController" bundle:nil];
            viewController.tmdbActor = person;
            viewController.closeHandler = ^{
                [cell animateShrinkWithCompletion:^{}];
            };
            [self presentViewController:viewController animated:NO completion:^{}];
        }];
    }];
    
    connection.activityIndicator = cell.activityIndicator;
    [self.connectionsManager startConnection:connection];
}

#pragma mark - Images

- (IBAction)photosButtonPressed:(id)sender {
    if (!self.tmdbMovie.backdropsImages) {
        MovieImagesConnection* connection = [[MovieImagesConnection alloc] initWithTmdbMovie:self.tmdbMovie completionHandler:^(WebserviceResultCode code, TmdbMovie *movie) {
            [self openImages];
        }];
        [self startConnection:connection];
    }
    else {
        [self openImages];
    }
    
}

- (void)openImages {
    
    ImagesViewController* viewController = [[ImagesViewController alloc] initWithNibName:@"ImagesViewController" bundle:nil];
    viewController.images = self.tmdbMovie.backdropsImages;
    viewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:viewController animated:YES completion:^{}];
    
}

- (IBAction)trailerButtonPressed:(id)sender {
    
    if (!self.tmdbMovie.trailerPath) {
        MovieTrailersConnection* connection = [[MovieTrailersConnection alloc] initWithTmdbMovie:self.tmdbMovie completionHandler:^(WebserviceResultCode code, TmdbMovie *movie) {
            if (code == WebserviceResultOk) {
                [self playTrailer];
            }
        }];
        
        [self startConnection:connection];
    }
    else {
        [self playTrailer];
    }
}

- (void)playTrailer {

    switch (self.tmdbMovie.trailerType) {
        case TmdbTrailerQuicktimeType:
        {
            MPMoviePlayerViewController* viewController = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:self.tmdbMovie.trailerPath]];
            [self presentMoviePlayerViewControllerAnimated:viewController];
        }
            break;
        case TmdbTrailerYoutubeType:
        {
            YouTubeViewController* viewController = [[YouTubeViewController alloc] initWithNibName:@"YouTubeViewController" bundle:nil];
            viewController.youtubeId = self.tmdbMovie.trailerPath;
            [self presentViewController:viewController animated:YES completion:nil];
        }
            break;
        default:
            break;
    }

}

@end
