//
//  SortingMoviesViewController.m
//  Moobeez
//
//  Created by Radu Banea on 13/10/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "SortingMoviesViewController.h"
#import "Moobeez.h"

@interface SortingMoviesViewController () <SortingViewDataSource, SortingViewDelegate>

@property (weak, nonatomic) IBOutlet SortingView* sortingView;

@property (strong, nonatomic) NSMutableArray* movies;

@end

@implementation SortingMoviesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    MoviesListConnection* connection = [[MoviesListConnection alloc] initWithType:MoviesNowPlayingType completionHandler:^(WebserviceResultCode code, NSMutableArray *movies) {
        if (code == WebserviceResultOk) {
            self.movies = movies;
            [self.sortingView reloadData];
        }
    }];
    
    [self startConnection:connection];
    
}

- (NSInteger)numberOfCardsInSortingView:(SortingView *)sortingView {
    return self.movies.count;
}

- (UIView*)sortingView:(SortingView *)sortingView viewForCardIndex:(NSInteger)cardIndex {
    
    MovieCardView* cardView = [[NSBundle mainBundle] loadNibNamed:@"MovieCardView" owner:self options:nil][0];

    cardView.movie = self.movies[cardIndex];
    
    return cardView;
}

- (UIView*)sortingView:(SortingView *)sortingView coverViewForCard:(UIView *)cardView direction:(SortingDirection)direction {
    
    switch (direction) {
        case SortingLeft:
            return ((MovieCardView*) cardView).leftCoverView;
            break;
        case SortingRight:
            return ((MovieCardView*) cardView).rightCoverView;
            break;
        default:
            break;
    }
    
}


@end
