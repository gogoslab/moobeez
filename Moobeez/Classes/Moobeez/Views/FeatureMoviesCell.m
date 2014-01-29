//
//  FeatureMoviesCell.m
//  Moobeez
//
//  Created by Radu Banea on 22/01/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "FeatureMoviesCell.h"
#import "Moobeez.h"

@interface FeatureMoviesCell ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) NSMutableArray* posterViews;
@property (strong, nonatomic) NSMutableArray* unusedPosterViews;

@property (readwrite, nonatomic) BOOL isAnimationRunning;
@property (readwrite, nonatomic) BOOL isMoving;

@property (weak, nonatomic) IBOutlet UIView *postersContentView;

@property (readwrite, nonatomic) CGPoint lastPanLocation;

@end

@implementation FeatureMoviesCell

- (void)awakeFromNib {
    self.height = [MoviePosterView height];
    self.postersContentView.height = [MoviePosterView height] + 1;
}

- (void)setMovies:(NSArray *)movies {
    _movies = movies;
    
    for (MoviePosterView* posterView in self.posterViews) {
        [posterView removeFromSuperview];
        [self.unusedPosterViews addObject:posterView];
    }
    
    self.posterViews = [[NSMutableArray alloc] init];
    
    [self reloadPosters];
}

#pragma mark - Posters

- (MoviePosterView*)posterViewWithIndex:(NSInteger)index {
    
    for (MoviePosterView* posterView in self.posterViews) {
        if ([self.movies indexOfObject:posterView.movie] == index) {
            return posterView;
        }
    }
    
    return nil;
}

- (void)reloadPosters {
    
    NSMutableArray* visiblePosters = [NSMutableArray arrayWithArray:self.posterViews];
    
    for (MoviePosterView* posterView in visiblePosters) {
        
        if (posterView.x <= -50 || posterView.right >= self.postersContentView.width + 50) {
            
            [self.unusedPosterViews addObject:posterView];
            [self.posterViews removeObject:posterView];
            [posterView removeFromSuperview];
            
        }
        
    }

    CGFloat right = 0;
    
    if (self.posterViews.count) {
        right = [self.posterViews.lastObject right];
    }
    
    while (right < self.postersContentView.width + 50) {
        
        [self addPosterBefore:NO];
        
        right = [self.posterViews.lastObject right];
        
    }

    CGFloat left = 0;
    
    if (self.posterViews.count) {
        left = ((UIView*) self.posterViews[0]).x;
    }
    
    while (left > -50) {
        
        [self addPosterBefore:YES];
        
        left = ((UIView*) self.posterViews[0]).x;
        
    }
}

- (void)addPosterBefore:(BOOL)before {
    
    if (self.movies.count == 0) {
        return;
    }
    
    NSInteger movieIndex = 0;
    
    if (self.posterViews.count) {
        
        if (before) {
            movieIndex = [self.movies indexOfObject:((MoviePosterView*) self.posterViews[0]).movie];
            movieIndex = (movieIndex + self.movies.count - 1) % self.movies.count;
        }
        else {
            movieIndex = [self.movies indexOfObject:((MoviePosterView*) self.posterViews.lastObject).movie];
            movieIndex = (movieIndex + 1) % self.movies.count;
        }
        
    }
    
    TmdbMovie* movie = self.movies[movieIndex];
    
    MoviePosterView* posterView;
    
    if (self.unusedPosterViews.count) {
        posterView = self.unusedPosterViews.lastObject;
        [self.unusedPosterViews removeLastObject];
    }
    
    if (!posterView) {
        posterView = [[NSBundle mainBundle] loadNibNamed:@"MoviePosterView" owner:self options:nil][0];
        posterView.height = self.postersContentView.height;
        UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnPosterView:)];
        tapGesture.numberOfTapsRequired = 1;
        tapGesture.numberOfTouchesRequired = 1;
        [posterView addGestureRecognizer:tapGesture];
    }
    
    if (!before) {
        CGFloat lastRight = 0;
        
        if (self.posterViews.count > 0) {
            lastRight = [self.posterViews.lastObject right];
        }

        posterView.x = lastRight;
    }
    else {
        
        CGFloat lastX = self.postersContentView.width;
        
        if (self.posterViews.count > 0) {
            lastX = ((UIView*) self.posterViews[0]).x;
        }
        
        posterView.right = lastX;
    }
    
    posterView.movie = movie;
    
    [self.postersContentView addSubview:posterView];
    
    if (before) {
        [self.posterViews insertObject:posterView atIndex:0];
    }
    else {
        [self.posterViews addObject:posterView];
    }
}

#pragma mark - Animation

- (void)startAnimating {
    
    if (self.isAnimationRunning) {
        return;
    }
    
    if (!self.movies.count) {
        return;
    }
    
    self.isAnimationRunning = YES;
    
    if (!self.isMoving) {
        [self runAnimation];
    }
}

- (void)stopAnimating {
    
    self.isAnimationRunning = NO;
    
    for (MoviePosterView* posterView in self.posterViews) {
        [posterView.layer removeAllAnimations];
    }
    
}

- (void)runAnimation {
    
    self.isMoving = YES;
    
    [UIView animateWithDuration:2.0 delay:0 options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction animations:^{
        for (MoviePosterView* posterView in self.posterViews) {
            posterView.x -= (!self.isReverse ? 1 : -1) * 20;
        }
    } completion:^(BOOL finished) {
        [self reloadPosters];
        self.isMoving = NO;
        if (self.isAnimationRunning) {
            [self runAnimation];
//            [self performSelector:@selector(runAnimation) withObject:nil afterDelay:0.01];
        }
    }];
    
}

#pragma mark - Actions

- (IBAction)didPanned:(id)sender {
    
    UIPanGestureRecognizer* reconizer = (UIPanGestureRecognizer*) sender;
    
    switch (reconizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            [self stopAnimating];
            self.lastPanLocation = [reconizer locationInView:self.contentView];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint panLocation = [reconizer locationInView:self.contentView];
            
            CGFloat delta = self.lastPanLocation.x - panLocation.x;
            
            CGFloat duration = 0.01;//fabs(delta) / 50;
            
            [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction animations:^{
                for (MoviePosterView* posterView in self.posterViews) {
                    posterView.x -= delta;
                }
                [self reloadPosters];
            } completion:^(BOOL finished) {
            }];

            self.lastPanLocation = panLocation;
            
            self.isReverse = (delta < 0);
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            [self startAnimating];
        }
            break;
            
        default:
            break;
    }
    
}

- (IBAction)expandButtonPressed:(id)sender {
    if ([self.parentTableView.delegate respondsToSelector:@selector(tableView:accessoryButtonTappedForRowWithIndexPath:)]) {
        [self.parentTableView.delegate tableView:self.parentTableView accessoryButtonTappedForRowWithIndexPath:[self.parentTableView indexPathForCell:self]];
    }
}

- (IBAction)didTapOnPosterView:(id)sender {
    
    MoviePosterView* posterView = (MoviePosterView*) ((UITapGestureRecognizer*) sender).view;
    
    if ([self.parentTableView.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
        
        NSIndexPath* indexPath = [self.parentTableView indexPathForCell:self];
        indexPath = [NSIndexPath indexPathForRow:[self.movies indexOfObject:posterView.movie] inSection:indexPath.section];

        [self.parentTableView.delegate tableView:self.parentTableView didSelectRowAtIndexPath:indexPath];
    }
}
@end
