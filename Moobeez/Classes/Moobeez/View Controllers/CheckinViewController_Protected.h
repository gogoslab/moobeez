//
//  CheckinViewController_Protected.h
//  Moobeez
//
//  Created by Radu Banea on 05/09/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "CheckinViewController.h"
#import "Moobeez.h"

typedef enum : NSUInteger {
    SectionSearch,
    SectionWatchlist,
    SectionsCount,
} Sections;

@interface CheckinViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, CLLocationManagerDelegate, FBPlacePickerDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *moviesView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) NSMutableArray* searchItems;
@property (readonly, nonatomic) NSMutableArray* userMovies;
@property (strong, nonatomic) NSMutableArray* watchlistMovies;

@property (strong, nonatomic) NSIndexPath* selectedMovieIndexPath;

@property (weak, nonatomic) IBOutlet UIView *placesView;
@property (strong, nonatomic) NSIndexPath* selectedPlaceIndexPath;

@property (weak, nonatomic) IBOutlet UIView *friendsView;
@property (weak, nonatomic) IBOutlet UICollectionView *friendsCollectionView;
@property (strong, nonatomic) NSMutableArray* friends;

@property (strong, nonatomic) SearchNewMovieViewController* searchNewMovieController;
@property (strong, nonatomic) SearchNewPlaceViewController* searchNewPlaceController;
@property (strong, nonatomic) SearchNewFriendViewController* searchNewFriendController;

@property (strong, nonatomic) CLLocationManager *locationManager;

@property (weak, nonatomic) IBOutlet UIView *commentsView;
@property (weak, nonatomic) IBOutlet UIButton *commentsButton;
@property (weak, nonatomic) IBOutlet UITextView *commentsTextView;

@property (strong, nonatomic) IBOutlet UIView *facebookView;

@end


