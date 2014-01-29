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
#import <FacebookSDK/FacebookSDK.h>
#import <Social/Social.h>

@interface MovieViewController () <UITextFieldDelegate, ToolboxViewDelegate>

@property (weak, nonatomic) IBOutlet ImageView *posterImageView;

@property (strong, nonatomic) IBOutlet MovieToolboxView *toolboxView;

@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *hideToolboxRecognizer;

@property (weak, nonatomic) IBOutlet UIButton *addButton;


@property (strong, nonatomic) TextViewController* descriptionViewController;
@property (strong, nonatomic) CastViewController* castViewController;

@property (weak, nonatomic) IBOutlet BubbleUpsideDownPopupView *shareBubbleView;
@property (weak, nonatomic) IBOutlet UIView *shareButtonsView;
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
    
    [self.posterImageView loadImageWithPath:self.moobee.posterPath andWidth:185 completion:^(BOOL didLoadImage) {
        
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

- (IBAction)addButtonPressed:(id)sender {
    if([self.moobee save]) {
        self.addButton.hidden = YES;
    }
}

- (IBAction)hideToolbox:(id)sender {
    if (!self.shareBubbleView.hidden) {
        self.shareBubbleView.hidden = YES;
    }
    else if (self.toolboxView.isFullyDisplayed) {
        [self.toolboxView hideFullToolbox];
    }
}

/*
- (void)toolboxViewDidShow:(ToolboxView *)toolboxView {
    [self.posterImageView addGestureRecognizer:self.hideToolboxRecognizer];
}

- (void)toolboxViewWillHide:(ToolboxView *)toolboxView {
    [self.posterImageView removeGestureRecognizer:self.hideToolboxRecognizer];
}
*/

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
        if (code == WebserviceResultOk) {
            [cell animateGrowWithCompletion:^{
                ActorViewController* viewController = [[ActorViewController alloc] initWithNibName:@"ActorViewController" bundle:nil];
                viewController.tmdbActor = person;
                viewController.closeHandler = ^{
                    [cell animateShrinkWithCompletion:^{}];
                };
                [self presentViewController:viewController animated:NO completion:^{}];
            }];
        }
    }];
    
    connection.activityIndicator = cell.activityIndicator;
    [self.connectionsManager startConnection:connection];
}

- (void)openPerson:(TmdbPerson*)person fromCharacterCell:(CharacterCell*)cell {
    PersonConnection* connection = [[PersonConnection alloc] initWithTmdbId:person.id completionHandler:^(WebserviceResultCode code, TmdbPerson *person) {
        if (code == WebserviceResultOk) {
            [cell animateGrowWithCompletion:^{
                ActorViewController* viewController = [[ActorViewController alloc] initWithNibName:@"ActorViewController" bundle:nil];
                viewController.tmdbActor = person;
                viewController.closeHandler = ^{
                    [cell animateShrinkWithCompletion:^{}];
                };
                [self presentViewController:viewController animated:NO completion:^{}];
            }];
        }
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

#pragma mark - Share

- (IBAction)shareButtonPressed:(id)sender {
    
    if (self.shareBubbleView.hidden) {
        
        self.shareButtonsView.hidden = YES;
        self.shareBubbleView.hidden = NO;
        
        [self.shareBubbleView startAnimation];
        self.shareBubbleView.animationCompletionHandler = ^{
            self.shareButtonsView.hidden = NO;
            self.shareBubbleView.sourceButton.hidden = YES;
        };
    }
    else {
        self.shareBubbleView.hidden = YES;
    }
    
}

- (NSString*)sharedText {
    NSString* text;
    
    if (self.moobee.type == MoobeeSeenType) {

        switch (((int) self.moobee.rating)) {
            case 0:
                text = [NSString stringWithFormat:@"Just saw %@, didn't like it that much...actually I didn't like it at all!", self.moobee.name];
                break;
            case 1:
                text = [NSString stringWithFormat:@"Just saw %@, didn't like it that much!", self.moobee.name];
                break;
            case 2:
                text = [NSString stringWithFormat:@"Just saw %@, it's ok, but I don't think I would watch it again soon.", self.moobee.name];
                break;
            case 3:
                text = [NSString stringWithFormat:@"Just saw %@, it's great, you should really watch it!", self.moobee.name];
                break;
            case 4:
                text = [NSString stringWithFormat:@"Wow! Just saw %@, it's incredible, I need to see it again! Awesome!!!", self.moobee.name];
                break;
            case 5:
                text = [NSString stringWithFormat:@"OMG! Just saw the best movie ever! %@! It's just unbelievable! It's a must, just blew my mind!", self.moobee.name];
                break;
            default:
                break;
        }
        
    }
    else {
        text = [NSString stringWithFormat:@"Check out %@, seems like a great movie and i'm planning to see it!", self.moobee.name];
    }
    
    return text;
}

#pragma mark Facebook

- (IBAction)facebookButtonPressed:(id)sender {

    FBShareDialogParams *params = [[FBShareDialogParams alloc] init];
    params.link = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.imdb.com/title/%@/", self.tmdbMovie.imdbId]];
    params.name = self.tmdbMovie.name;
    params.description = self.sharedText;
    
    
    // If the Facebook app is installed and we can present the share dialog
    if ([FBDialogs canPresentShareDialogWithParams:params]) {
        
        // Present share dialog
        [FBDialogs presentShareDialogWithLink:params.link
                                         name:params.name
                                      caption:params.caption
                                  description:params.description
                                      picture:params.picture
                                  clientState:nil
                                      handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                          if(error) {
                                              // An error occurred, we need to handle the error
                                              // See: https://developers.facebook.com/docs/ios/errors
                                              NSLog([NSString stringWithFormat:@"Error publishing story: %@", error.description]);
                                          } else {
                                              // Success
                                              NSLog(@"result %@", results);
                                          }
                                      }];
        
        // If the Facebook app is NOT installed and we can't present the share dialog
    } else {
        // FALLBACK: publish just a link using the Feed dialog
        
        // Put together the dialog parameters
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       self.tmdbMovie.name, @"name",
                                       self.sharedText, @"description",
                                       [NSString stringWithFormat:@"http://www.imdb.com/title/%@/", self.tmdbMovie.imdbId], @"link",
                                       nil];
        
        // Show the feed dialog
        [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                               parameters:params
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      if (error) {
                                                          // An error occurred, we need to handle the error
                                                          // See: https://developers.facebook.com/docs/ios/errors
                                                          NSLog([NSString stringWithFormat:@"Error publishing story: %@", error.description]);
                                                      } else {
                                                          if (result == FBWebDialogResultDialogNotCompleted) {
                                                              // User canceled.
                                                              NSLog(@"User cancelled.");
                                                          } else {
                                                              // Handle the publish feed callback
                                                              NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                                                              
                                                              if (![urlParams valueForKey:@"post_id"]) {
                                                                  // User canceled.
                                                                  NSLog(@"User cancelled.");
                                                                  
                                                              } else {
                                                                  // User clicked the Share button
                                                                  NSString *result = [NSString stringWithFormat: @"Posted story, id: %@", [urlParams valueForKey:@"post_id"]];
                                                                  NSLog(@"result %@", result);
                                                              }
                                                          }
                                                      }
                                                  }];
    }
}

// A function for parsing URL parameters returned by the Feed Dialog.
- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}

#pragma mark Twitter

- (IBAction)twitterButtonPressed:(id)sender {
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:self.sharedText];
        [self presentViewController:tweetSheet animated:YES completion:nil];
    }
    
}



@end
