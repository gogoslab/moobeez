//
//  MoviesSuggestionsViewController.m
//  Moobeez
//
//  Created by Radu Banea on 13/10/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "MoviesSuggestionsViewController.h"
#import "Moobeez.h"

#define MAX_PAGE 2

@interface MoviesSuggestionsViewController () <SortingViewDataSource, SortingViewDelegate>

@property (weak, nonatomic) IBOutlet SortingView* sortingView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *reloadView;
@property (weak, nonatomic) IBOutlet UILabel *noSuggestionsLabel;

@property (strong, nonatomic) NSMutableArray* movies;

@property (strong, nonatomic) ImageView* animationPosterView;

@property (readwrite, nonatomic) NSInteger currentPage;

@end

@implementation MoviesSuggestionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.currentPage = -1;
    self.reloadView.hidden = YES;
    self.noSuggestionsLabel.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.currentPage == -1) {
        self.currentPage = 0;
        [self reloadData];
    }

    if (!self.noSuggestionsLabel.hidden) {
        self.currentPage = 0;
        self.noSuggestionsLabel.hidden = YES;
        self.reloadView.hidden = NO;
    }

}

- (void)loadPage:(NSInteger)page {
    
    self.movies = [[NSMutableArray alloc] init];
    
    MoviesListConnection* connection = [[MoviesListConnection alloc] initWithType:MoviesNowPlayingType page:page completionHandler:^(WebserviceResultCode code, NSMutableArray *movies) {
        if (code == WebserviceResultOk) {
            for (TmdbMovie* movie in movies) {
                Moobee* moobee = [Moobee moobeeWithTmdbMovie:movie];
                if (moobee.id == -1) {
                    moobee.type = MoobeeNewType;
                    [moobee save];
                }
            }
            MoviesListConnection* connection = [[MoviesListConnection alloc] initWithType:MoviesUpcomingType page:page completionHandler:^(WebserviceResultCode code, NSMutableArray *movies) {
                if (code == WebserviceResultOk) {
                    for (TmdbMovie* movie in movies) {
                        Moobee* moobee = [Moobee moobeeWithTmdbMovie:movie];
                        if (moobee.id == -1) {
                            moobee.type = MoobeeNewType;
                            [moobee save];
                        }
                    }
                    [self reloadData];
                }
            }];
            
            [self startConnection:connection];
        }
    }];
    
    [self startConnection:connection];
    
}

- (void)reloadData {
    
    self.movies = [[Database sharedDatabase] moobeezWithType:MoobeeNewType];
    
    if (self.movies.count) {
        self.contentView.hidden = NO;
        [self.sortingView reloadData];
    }
    else if (self.currentPage <= MAX_PAGE){
        [self loadNextPage];
    }
    else {
        self.noSuggestionsLabel.hidden = NO;
    }
}

- (void)loadNextPage {
    self.currentPage++;
    self.contentView.hidden = YES;
    [self loadPage:self.currentPage];
}

- (NSInteger)numberOfCardsInSortingView:(SortingView *)sortingView {
    return self.movies.count;
}

- (UIView*)sortingView:(SortingView *)sortingView viewForCardIndex:(NSInteger)cardIndex {
    
    MovieCardView* cardView = (MovieCardView*) [sortingView dequeueReusableCard];
    
    if (!cardView) {
        cardView = [[NSBundle mainBundle] loadNibNamed:@"MovieCardView" owner:self options:nil][0];
    }

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

- (void)sortingView:(SortingView *)sortingView didSortCardAtIndex:(NSInteger)cardIndex direction:(SortingDirection)direction {
    
    Moobee* moobee = self.movies[cardIndex];
    
    switch (direction) {
        case SortingLeft:
            moobee.type = MoobeeDiscardedType;
            break;
        case SortingRight:
            moobee.type = MoobeeOnWatchlistType;
            break;
        default:
            break;
    }
    
    [moobee save];
    
    if (cardIndex == 0) {
        if (self.currentPage <= MAX_PAGE) {
            self.contentView.hidden = YES;
            self.reloadView.hidden = NO;
        }
        else {
            self.noSuggestionsLabel.hidden = NO;
        }
    }
}

- (IBAction)reloadMoviesButtonPressed:(id)sender {
    self.reloadView.hidden = YES;
    [self loadNextPage];
}


- (void)sortingView:(SortingView *)sortingView didSelectCardAtIndex:(NSInteger)cardIndex {
    
    ImageView* posterView = [[ImageView alloc] initWithFrame:sortingView.cardFrame];
    [self.appDelegate.window addSubview:posterView];
    
    CGRect cardRect = [sortingView.topCardView.superview convertRect:sortingView.topCardView.frame toView:self.appDelegate.window];
    posterView.frame = cardRect;
    
    posterView.contentMode = UIViewContentModeScaleAspectFill;
    posterView.clipsToBounds = YES;
    
    Moobee* moobee = self.movies[cardIndex];
    
    [posterView loadPosterWithPath:moobee.posterPath completion:^(BOOL didLoadImage) {
        posterView.defaultImage = posterView.image;
    }];
    
    self.animationPosterView = posterView;
    
    [UIView animateWithDuration:0.33 animations:^{
        posterView.frame = self.appDelegate.window.bounds;
        [posterView loadPosterWithPath:moobee.posterPath completion:^(BOOL didLoadImage) {
            
        }];
    } completion:^(BOOL finished) {
        
        self.view.userInteractionEnabled = NO;
        MovieConnection* connection = [[MovieConnection alloc] initWithTmdbId:moobee.tmdbId completionHandler:^(WebserviceResultCode code, TmdbMovie *movie) {
            if (code == WebserviceResultOk) {
                self.view.userInteractionEnabled = YES;
                
                MovieViewController* viewController = [[MovieViewController alloc] initWithNibName:@"MovieViewController" bundle:nil];
                viewController.moobee = moobee;
                viewController.tmdbMovie = movie;
                
                moobee.posterPath = movie.posterPath;
                moobee.backdropPath = movie.backdropPath;
                moobee.releaseDate = movie.releaseDate;
                
                [self.navigationController pushViewController:viewController animated:NO];

                viewController.closeHandler = ^{

                    [self.appDelegate.window addSubview:self.animationPosterView];
                    
                    [UIView animateWithDuration:0.33 animations:^{
                        self.animationPosterView.frame = cardRect;
                    } completion:^(BOOL finished) {
                        [self.animationPosterView removeFromSuperview];
                    }];
                    
                    [self.sortingView setNeedsDisplayInRect:self.sortingView.bounds];
                    
                };
                
                [posterView removeFromSuperview];
            }
        }];
        [self startConnection:connection];
        
    }];
    
}


@end
