//
//  CheckinShowViewController.m
//  Moobeez
//
//  Created by Radu Banea on 05/09/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "CheckinShowViewController.h"
#import "CheckinViewController_Protected.h"

@interface CheckinShowViewController ()

@property (strong, nonatomic) SearchNewTvViewController* searchNewTvShowController;

@end

@implementation CheckinShowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"Check-in TV Show";
    
    self.commentsTextView.text = @"Watching my favorite show!";
}

- (NSMutableArray*)userMovies {
    return [[Database sharedDatabase] teebeezActive];
}

- (IBAction)checkinButtonPressed:(id)sender {
    
    if (!self.selectedMovieIndexPath) {
        return;
    }
    
    
    NSInteger tmdbId = -1;
    
    if (self.selectedMovieIndexPath.section == 0) {
        TmdbTV* movie = self.searchItems[self.selectedMovieIndexPath.row];
        tmdbId = movie.id;
    }
    else {
        Teebee* teebee = self.watchlistMovies[self.selectedMovieIndexPath.row];
        tmdbId = teebee.tmdbId;
    }
    
    TvConnection* connection = [[TvConnection alloc] initWithTmdbId:tmdbId completionHandler:^(WebserviceResultCode code, TmdbTV *tv) {
        if (code == WebserviceResultOk) {
            [self shareItem:tv];
        }
    }];
    [self startConnection:connection];
    
}

- (void)shareItem:(id)item {
    
    TmdbTV* movie = (TmdbTV*) item;
    
    if (!FBSession.activeSession.isOpen) {
        // if the session isn't open, we open it here, which may cause UX to log in the user
        [FBSession openActiveSessionWithReadPermissions:nil
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                          if (!error) {
                                              [FBSession setActiveSession:session];
                                              [self shareItem:movie];
                                          } else {
                                              [[[UIAlertView alloc] initWithTitle:@"Error"
                                                                          message:error.localizedDescription
                                                                         delegate:nil
                                                                cancelButtonTitle:@"OK"
                                                                otherButtonTitles:nil]
                                               show];
                                          }
                                      }];
    }
    
    
    NSString* moviePosterPath = [ImageView imagePath:movie.posterPath forWidth:185];
    
    NSMutableDictionary<FBOpenGraphObject> *object =
    [FBGraphObject openGraphObjectForPostWithType:@"video.tv_show"
                                            title:movie.name
                                            image:moviePosterPath
                                              url:[movie.imdbUrl absoluteString]
                                      description:movie.overview];
    
    [FBRequestConnection startForPostOpenGraphObject:object
                                   completionHandler:^(FBRequestConnection *connection,
                                                       id result,
                                                       NSError *error) {
                                       // handle the result
                                       
                                       if(!error) {
                                           
                                           NSString *objectId = [result objectForKey:@"id"];
                                           NSLog(@"%@", [NSString stringWithFormat:@"object id: %@", objectId]);
                                           
                                           // Further code to post the OG story goes here
                                           
                                           // create an Open Graph action
                                           id<FBOpenGraphAction> action = (id<FBOpenGraphAction>)[FBGraphObject graphObject];
                                           [action setObject:objectId forKey:@"tv_show"];
                                           if (self.selectedPlaceIndexPath) {
                                               action[@"place"] = self.data[self.selectedPlaceIndexPath.row];
                                           }
                                           action[@"message"] = self.commentsTextView.text;
                                           action[@"expires_in"] = @"7200";
                                           action[@"fb:explicitly_shared"] = @"true";
                                           action[@"tags"] = [[self.friends valueForKey:@"id"] componentsJoinedByString:@","];
                                           
                                           // create action referencing user owned object
                                           [FBRequestConnection startForPostWithGraphPath:@"/me/video.watches?fb:explicitly_shared=true" graphObject:action completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                               
                                               [LoadingView hideLoadingView];
                                               
                                               if(!error) {
                                                   NSLog(@"%@", [NSString stringWithFormat:@"OG story posted, story id: %@", [result objectForKey:@"id"]]);
                                                   [self dismissViewControllerAnimated:YES completion:nil];
                                                   
                                                   [Alert showAlertViewWithTitle:@"Success" message:@"" buttonClickedCallback:^(NSInteger buttonIndex) {
                                                       
                                                   } cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                                   
                                               } else {
                                                   // An error occurred
                                                   NSLog(@"Encountered an error posting to Open Graph: %@", error);
                                                   
                                                   [Alert showAlertViewWithTitle:@"Error" message:@"An error occured while trying to post on facebook. Please try again" buttonClickedCallback:^(NSInteger buttonIndex) {
                                                       
                                                   } cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                               }
                                           }];
                                           
                                           
                                       } else {
                                           // An error occurred
                                           NSLog(@"Encountered an error posting to Open Graph: %@", error);
                                           
                                           [Alert showAlertViewWithTitle:@"Error" message:@"An error occured while trying to post on facebook. Please try again" buttonClickedCallback:^(NSInteger buttonIndex) {
                                               
                                               [LoadingView hideLoadingView];
                                               
                                           } cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                       }
                                   }];
    
    
    [LoadingView showLoadingViewWithContent:nil];
}


- (IBAction)searchButtonPressed:(id)sender {
    
    [self.appDelegate.window addSubview:self.searchNewTvShowController.view];
    
    __block CheckinShowViewController *weakSelf = self;

    self.searchNewTvShowController.selectHandler = ^ (TmdbTV* tv) {
        
        [weakSelf.searchItems insertObject:tv atIndex:0];
        [weakSelf.collectionView reloadData];
        [weakSelf.collectionView setContentOffset:CGPointZero animated:YES];
        
        [weakSelf.searchNewMovieController.view removeFromSuperview];
        
    };
    
}

- (SearchNewTvViewController*)searchNewTvShowController {
    if (!_searchNewTvShowController) {
        _searchNewTvShowController = [[SearchNewTvViewController alloc] initWithNibName:@"SearchNewTvViewController" bundle:nil];
        _searchNewTvShowController.view.frame = self.appDelegate.window.bounds;
    }
    
    return _searchNewTvShowController;
}

@end
