//
//  CheckinViewController.m
//  Moobeez
//
//  Created by Radu Banea on 17/07/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "CheckinViewController.h"
#import "Moobeez.h"

typedef enum : NSUInteger {
    SectionSearch,
    SectionWatchlist,
    SectionsCount,
} Sections;

@interface CheckinViewController () <UICollectionViewDataSource, UICollectionViewDelegate, CLLocationManagerDelegate, FBPlacePickerDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *moviesView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) NSMutableArray* searchItems;
@property (strong, nonatomic) NSMutableArray* watchlistMovies;

@property (strong, nonatomic) NSIndexPath* selectedMovieIndexPath;

@property (weak, nonatomic) IBOutlet UIView *placesView;
@property (strong, nonatomic) NSIndexPath* selectedPlaceIndexPath;

@property (strong, nonatomic) SearchNewMovieViewController* searchNewMovieController;
@property (strong, nonatomic) SearchNewPlaceViewController* searchNewPlaceController;

@property (strong, nonatomic) CLLocationManager *locationManager;

@property (weak, nonatomic) IBOutlet UIView *commentsView;
@property (weak, nonatomic) IBOutlet UIButton *commentsButton;
@property (weak, nonatomic) IBOutlet UITextView *commentsTextView;

@end

@implementation CheckinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"Check-in to movie";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"close_button.png"] style:UIBarButtonItemStylePlain target:self action:@selector(closeButtonPressed:)];
    
    self.searchText = @"Cinema";
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"CheckInMovieCell" bundle:nil] forCellWithReuseIdentifier:@"CheckInMovieCell"];
    [self.placesTableView registerNib:[UINib nibWithNibName:@"CheckInPlaceCell" bundle:nil] forCellReuseIdentifier:@"CheckInPlaceCell"];
    
    self.searchItems = [[NSMutableArray alloc] init];
    self.watchlistMovies = [[Database sharedDatabase] moobeezWithType:MoobeeOnWatchlistType];
    [self.collectionView reloadData];
    
    [self refresh];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willShowKeyboard:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willHideKeyboard:) name:UIKeyboardWillHideNotification object:nil];
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

- (IBAction)checkinButtonPressed:(id)sender {

    if (!self.selectedMovieIndexPath) {
        return;
    }
    
    if (self.selectedMovieIndexPath.section == 0) {
        TmdbMovie* movie = self.searchItems[self.selectedMovieIndexPath.row];
        [self shareMovie:movie];
    }
    else {
        Moobee* moobee = self.watchlistMovies[self.selectedMovieIndexPath.row];
        MovieConnection* connection = [[MovieConnection alloc] initWithTmdbId:moobee.tmdbId completionHandler:^(WebserviceResultCode code, TmdbMovie *movie) {
            if (code == WebserviceResultOk) {
                [self shareMovie:movie];
            }
        }];
        [self startConnection:connection];
    }
}

- (void)shareMovie:(TmdbMovie*)movie {
    
    NSString* moviePosterPath = [ImageView imagePath:movie.posterPath forWidth:185];
    
    // instantiate a Facebook Open Graph object
    NSMutableDictionary<FBOpenGraphObject> *object = [FBGraphObject openGraphObjectForPost];
    
    // specify that this Open Graph object will be posted to Facebook
    object.provisionedForPost = YES;
    
    // for og:title
    object[@"title"] = movie.name;
    
    // for og:type, this corresponds to the Namespace you've set for your app and the object type name
    object[@"type"] = @"moobeez:moobee";
    
    // for og:description
    object[@"description"] = movie.overview;
    
    // for og:url, we cover how this is used in the "Deep Linking" section below
    object[@"url"] = [movie.imdbUrl absoluteString];
    
    // for og:image we assign the image that we just staged, using the uri we got as a response
    // the image has to be packed in a dictionary like this:
    object[@"image"] = @[@{@"url":moviePosterPath, @"user_generated" : @"false" }];
    
    // Post custom object
    [FBRequestConnection startForPostOpenGraphObject:object completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if(!error) {
            // get the object ID for the Open Graph object that is now stored in the Object API
            NSString *objectId = [result objectForKey:@"id"];
            NSLog(@"%@", [NSString stringWithFormat:@"object id: %@", objectId]);
            
            // Further code to post the OG story goes here
            
            // create an Open Graph action
            id<FBOpenGraphAction> action = (id<FBOpenGraphAction>)[FBGraphObject graphObject];
            [action setObject:objectId forKey:@"moobee"];
            if (self.selectedPlaceIndexPath) {
                action[@"place"] = self.data[self.selectedPlaceIndexPath.row];
            }
            action[@"message"] = self.commentsTextView.text;
            action[@"expires_in"] = @"7200";
            action[@"fb:explicitly_shared"] = @"true";
            
            // create action referencing user owned object
            [FBRequestConnection startForPostWithGraphPath:@"/me/moobeez:is_watching?fb:explicitly_shared=true" graphObject:action completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {

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
            NSLog(@"Error posting the Open Graph object to the Object API: %@", error);
            [LoadingView hideLoadingView];
            [Alert showAlertViewWithTitle:@"Error" message:@"An error occured while trying to post on facebook. Please try again" buttonClickedCallback:^(NSInteger buttonIndex) {
                
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
    return SectionsCount;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    switch (section) {
        case SectionSearch:
            return self.searchItems.count;
            break;
        case SectionWatchlist:
            return self.watchlistMovies.count;
        default:
            break;
    }
    
    return 0;
    
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CheckInMovieCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CheckInMovieCell" forIndexPath:indexPath];
    
    switch (indexPath.section) {
        case SectionSearch:
        {
            [cell.posterImageView loadImageWithPath:[self.searchItems[indexPath.row] posterPath] andWidth:185 completion:^(BOOL didLoadImage) {
                
            }];
        }
            break;
        case SectionWatchlist:
        {
            [cell.posterImageView loadImageWithPath:[self.watchlistMovies[indexPath.row] posterPath] andWidth:185 completion:^(BOOL didLoadImage) {
                
            }];
        }
        default:
            break;
    }

    cell.checkmarkImageView.hidden = !([indexPath isEqual:self.selectedMovieIndexPath]);
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    self.selectedMovieIndexPath = indexPath;
    [collectionView reloadData];
    
    if (!self.navigationItem.rightBarButtonItem && self.selectedMovieIndexPath) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"done_button.png"] style:UIBarButtonItemStylePlain target:self action:@selector(checkinButtonPressed:)];
    }

    
}

#pragma mark - Search

- (IBAction)searchButtonPressed:(id)sender {
    
    [self.appDelegate.window addSubview:self.searchNewMovieController.view];
    
    self.searchNewMovieController.selectHandler = ^ (TmdbMovie* movie) {
        
        [self.searchItems insertObject:movie atIndex:0];
        [self.collectionView reloadData];
        [self.collectionView setContentOffset:CGPointZero animated:YES];
        
        [self.searchNewMovieController.view removeFromSuperview];

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
    
    self.searchNewPlaceController.selectHandler = ^ (id place) {
        
        [self.data insertObject:place atIndex:0];
        self.selectedPlaceIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.placesTableView reloadData];
        [self.placesTableView setContentOffset:CGPointZero animated:YES];
        
        [self.searchNewPlaceController.view removeFromSuperview];
        
        if (!self.navigationItem.rightBarButtonItem && self.selectedMovieIndexPath && self.selectedPlaceIndexPath) {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"done_button.png"] style:UIBarButtonItemStylePlain target:self action:@selector(checkinButtonPressed:)];
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
        self.commentsView.frame = CGRectMake(0, 0, self.commentsView.frame.size.width, self.view.height - keyboardFrame.size.height);
        
    }];
}

- (void)willHideKeyboard:(NSNotification*)notification {
    
    CFTimeInterval animationDuration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    self.commentsButton.selected = NO;
    
    [UIView animateWithDuration:animationDuration animations:^{
        
        self.moviesView.transform = CGAffineTransformIdentity;
        self.placesView.transform = CGAffineTransformIdentity;
        self.commentsView.frame = CGRectMake(0, self.placesView.bottom, self.commentsView.frame.size.width, self.view.height - self.placesView.bottom);
        
    }];
}



@end
