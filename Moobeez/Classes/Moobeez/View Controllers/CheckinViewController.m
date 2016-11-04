//
//  CheckinViewController.m
//  Moobeez
//
//  Created by Radu Banea on 17/07/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "CheckinViewController_Protected.h"

@implementation CheckinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"Check-in to movie";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"close_button.png"] style:UIBarButtonItemStylePlain target:self action:@selector(closeButtonPressed:)];
    
    self.searchText = @"Cinema";
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"CheckInMovieCell" bundle:nil] forCellWithReuseIdentifier:@"CheckInMovieCell"];
    [self.placesTableView registerNib:[UINib nibWithNibName:@"CheckInPlaceCell" bundle:nil] forCellReuseIdentifier:@"CheckInPlaceCell"];
    [self.friendsCollectionView registerNib:[UINib nibWithNibName:@"CheckInFriendCell" bundle:nil] forCellWithReuseIdentifier:@"CheckInFriendCell"];
    
    self.searchItems = [[NSMutableArray alloc] init];
    self.watchlistMovies = self.userMovies;
    [self.collectionView reloadData];
    
    [self refresh];
    
    self.friends = [[NSMutableArray alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willShowKeyboard:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willHideKeyboard:) name:UIKeyboardWillHideNotification object:nil];
    
    if (!FBSession.activeSession.isOpen) {
        self.facebookView.frame = self.view.bounds;
        [self.view addSubview:self.facebookView];
    }

}

- (void)viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray*)userMovies {
    return [[Database sharedDatabase] moobeezWithType:MoobeeOnWatchlistType];
}

- (IBAction)checkinButtonPressed:(id)sender {

    if (!self.selectedMovieIndexPath) {
        return;
    }
    
    
    NSInteger tmdbId = -1;
    
    if (self.selectedMovieIndexPath.section == 0) {
        TmdbMovie* movie = self.searchItems[self.selectedMovieIndexPath.row];
        tmdbId = movie.id;
    }
    else {
        Moobee* moobee = self.watchlistMovies[self.selectedMovieIndexPath.row];
        tmdbId = moobee.tmdbId;
    }
    
    MovieConnection* connection = [[MovieConnection alloc] initWithTmdbId:tmdbId completionHandler:^(WebserviceResultCode code, TmdbMovie *movie) {
        if (code == WebserviceResultOk) {
            [self shareItem:movie];
        }
    }];
    [self startConnection:connection];

}

- (void)shareItem:(id)item {
    
    TmdbMovie* movie = (TmdbMovie*) item;
    
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
    [FBGraphObject openGraphObjectForPostWithType:@"video.movie"
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
                                           [action setObject:objectId forKey:@"movie"];
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
                                                       [Flurry logEvent:@"Checkin"];
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

- (IBAction)closeButtonPressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}

#pragma mark - Movies

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    if (collectionView == self.collectionView) {
        return SectionsCount;
    }
    
    if (collectionView == self.friendsCollectionView) {
        return 1;
    }

    return 0;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (collectionView == self.collectionView) {
        switch (section) {
            case SectionSearch:
                return self.searchItems.count;
                break;
            case SectionWatchlist:
                return self.watchlistMovies.count;
            default:
                break;
        }
    }
    
    if (collectionView == self.friendsCollectionView) {
        return self.friends.count;
    }

    
    return 0;
    
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (collectionView == self.collectionView) {
        
        CheckInMovieCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CheckInMovieCell" forIndexPath:indexPath];
        
        switch (indexPath.section) {
            case SectionSearch:
            {
                [cell.posterImageView loadPosterWithPath:[self.searchItems[indexPath.row] posterPath] completion:^(BOOL didLoadImage) {
                    
                }];
            }
                break;
            case SectionWatchlist:
            {
                [cell.posterImageView loadPosterWithPath:[self.watchlistMovies[indexPath.row] posterPath] completion:^(BOOL didLoadImage) {
                    
                }];
            }
            default:
                break;
        }
        
        cell.checkmarkImageView.hidden = !([indexPath isEqual:self.selectedMovieIndexPath]);
        
        return cell;
    }
    
    if (collectionView == self.friendsCollectionView) {
        CheckInFriendCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CheckInFriendCell" forIndexPath:indexPath];
        
        NSDictionary* friend = self.friends[indexPath.row];
        
        [cell.pictureImageView loadImageWithPath:friend[@"picture"][@"data"][@"url"] completion:^(BOOL didLoadImage) {
            
        }];
        
        return cell;
    }

    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (collectionView != self.collectionView) {
        return;
    }
    
    self.selectedMovieIndexPath = indexPath;
    [collectionView reloadData];
    
    if (!self.navigationItem.rightBarButtonItem && self.selectedMovieIndexPath) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"done_button.png"] style:UIBarButtonItemStylePlain target:self action:@selector(checkinButtonPressed:)];
    }

    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.collectionView) {
        return CGSizeMake(102, collectionView.height);
    }
    else {
        return CGSizeMake(collectionView.height, collectionView.height);
    }
    
}

#pragma mark - Search

- (IBAction)searchButtonPressed:(id)sender {
    
    [self.appDelegate.window addSubview:self.searchNewMovieController.view];
    
    __block CheckinViewController *weakSelf = self;
    
    self.searchNewMovieController.selectHandler = ^ (TmdbMovie* movie) {
        
        [weakSelf.searchItems insertObject:movie atIndex:0];
        [weakSelf.collectionView reloadData];
        [weakSelf.collectionView setContentOffset:CGPointZero animated:YES];
        
        [weakSelf.searchNewMovieController.view removeFromSuperview];

    };
    
}

- (SearchNewMovieViewController*)searchNewMovieController {
    if (!_searchNewMovieController) {
        _searchNewMovieController = [[SearchNewMovieViewController alloc] initWithNibName:@"SearchNewMovieViewController" bundle:nil];
        _searchNewMovieController.view.frame = self.appDelegate.window.bounds;
    }
    
    return _searchNewMovieController;
}


- (IBAction)searchPlaceButtonPressed:(id)sender {
    
    [self.appDelegate.window addSubview:self.searchNewPlaceController.view];
    
    __block CheckinViewController *weakSelf = self;
    
    self.searchNewPlaceController.selectHandler = ^ (id place) {
        
        [weakSelf.data insertObject:place atIndex:0];
        weakSelf.selectedPlaceIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [weakSelf.placesTableView reloadData];
        [weakSelf.placesTableView setContentOffset:CGPointZero animated:YES];
        
        [weakSelf.searchNewPlaceController.view removeFromSuperview];
        
        if (!weakSelf.navigationItem.rightBarButtonItem && weakSelf.selectedMovieIndexPath && weakSelf.selectedPlaceIndexPath) {
            weakSelf.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"done_button.png"] style:UIBarButtonItemStylePlain target:weakSelf action:@selector(checkinButtonPressed:)];
        }
        
    };
    
}
- (SearchNewPlaceViewController*)searchNewPlaceController {
    if (!_searchNewPlaceController) {
        _searchNewPlaceController = [[SearchNewPlaceViewController alloc] initWithNibName:@"SearchNewPlaceViewController" bundle:nil];
        _searchNewPlaceController.view.frame = self.appDelegate.window.bounds;
    }
    
    return _searchNewPlaceController;
}

- (IBAction)searchFriendButtonPressed:(id)sender {
    
    [self.appDelegate.window addSubview:self.searchNewFriendController.view];
    
    __block CheckinViewController *weakSelf = self;

    self.searchNewFriendController.selectHandler = ^ (id friend) {
        [weakSelf.friendsCollectionView reloadData];
    };
    
}

- (SearchNewFriendViewController*)searchNewFriendController {
    if (!_searchNewFriendController) {
        _searchNewFriendController = [[SearchNewFriendViewController alloc] initWithNibName:@"SearchNewFriendViewController" bundle:nil];
        _searchNewFriendController.view.frame = self.appDelegate.window.bounds;
        _searchNewFriendController.selectedFriends = self.friends;
    }
    
    return _searchNewFriendController;
}

#pragma mark - Location

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CheckInPlaceCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CheckInPlaceCell"];
    
    NSDictionary* place = self.data[indexPath.row];
    
    cell.nameLabel.text = place[@"name"];
    
    NSString *category = place[@"category"];
    NSNumber *wereHereCount = place[@"were_here_count"];
    
    NSString* subtitle = @"";
    
    if (wereHereCount) {
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        NSString *wereHere = [numberFormatter stringFromNumber:wereHereCount];
        
        if (category) {
            subtitle = [NSString stringWithFormat:@"%@ • %@ were here", [category capitalizedString], wereHere];
        }
        subtitle = [NSString stringWithFormat:@"%@ were here", wereHere];
    }
    if (category) {
        subtitle = [category capitalizedString];
    }
    
    cell.detailsLabel.text = subtitle;
    
    [cell.iconView loadImageWithPath:place[@"picture"][@"data"][@"url"] completion:^(BOOL didLoadImage) {}];
    
    cell.backgroundColor = [UIColor clearColor];
    
    cell.checkmarkImageView.hidden = (indexPath != self.selectedPlaceIndexPath);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.selectedPlaceIndexPath = indexPath;
    [tableView reloadData];
    
    if (!self.navigationItem.rightBarButtonItem && self.selectedMovieIndexPath && self.selectedPlaceIndexPath) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"done_button.png"] style:UIBarButtonItemStylePlain target:self action:@selector(checkinButtonPressed:)];
    }

}

#pragma mark - Comments 

- (IBAction)commentsButtonPressed:(id)sender {
    
    if (self.commentsButton.selected) {
        [self.commentsTextView resignFirstResponder];
    }
    else {
        [self.commentsTextView becomeFirstResponder];
    }
    
}


- (void)willShowKeyboard:(NSNotification*)notification {
    
    if (!self.commentsTextView.isFirstResponder) {
        return;
    }
    
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CFTimeInterval animationDuration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    self.commentsButton.selected = YES;
    
    [UIView animateWithDuration:animationDuration animations:^{
        
        self.moviesView.transform = CGAffineTransformMakeTranslation(0, -self.commentsView.y);
        self.placesView.transform = CGAffineTransformMakeTranslation(0, -self.commentsView.y);
        self.friendsView.transform = CGAffineTransformMakeTranslation(0, -self.commentsView.y);
        self.commentsView.frame = CGRectMake(0, 0, self.commentsView.frame.size.width, self.view.height - keyboardFrame.size.height);
        
    }];
}

- (void)willHideKeyboard:(NSNotification*)notification {
    
    CFTimeInterval animationDuration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    self.commentsButton.selected = NO;
    
    [UIView animateWithDuration:animationDuration animations:^{
        
        self.moviesView.transform = CGAffineTransformIdentity;
        self.placesView.transform = CGAffineTransformIdentity;
        self.friendsView.transform = CGAffineTransformIdentity;
        self.commentsView.frame = CGRectMake(0, self.friendsView.bottom, self.commentsView.frame.size.width, self.view.height - self.friendsView.bottom);
        
    }];
}

#pragma mark - Facebook

- (IBAction)facebookButtonPressed:(id)sender {
    
    if (!FBSession.activeSession.isOpen) {
        // if the session isn't open, we open it here, which may cause UX to log in the user
        [FBSession openActiveSessionWithReadPermissions:nil
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                          if (!error) {
                                              [FBSession setActiveSession:session];
                                              [self.facebookView removeFromSuperview];
                                              [self refresh];
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
}


@end
