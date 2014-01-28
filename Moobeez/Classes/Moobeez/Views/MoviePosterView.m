//
//  MoviePosterView.m
//  Moobeez
//
//  Created by Radu Banea on 22/01/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "MoviePosterView.h"
#import "Moobeez.h"

@interface MoviePosterView ()

@property (weak, nonatomic) IBOutlet ImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@end

@implementation MoviePosterView

- (void)setMovie:(TmdbMovie *)movie {
    
    _movie = movie;
    
    [self.imageView loadImageWithPath:movie.posterPath andWidth:185 completion:^(BOOL didLoadImage) {
        
    }];
    
}

+ (CGFloat)height {
    
    static CGFloat height = -1;
    
    if (height == -1) {
        
        MoviePosterView* cell = [[NSBundle mainBundle] loadNibNamed:@"MoviePosterView" owner:self options:nil][0];
        
        UIWindow* window = ((AppDelegate*) [UIApplication sharedApplication].delegate).window;
        
        height = cell.width * window.height / window.width;
        
    }
    
    return height;
}

- (void)animateGrowWithCompletion:(void (^)(void))completionHandler {
    
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    self.contentView.frame = self.bounds;
    [self addSubview:self.contentView];
    
    self.contentView.center = [appDelegate.window convertPoint:self.contentView.center fromView:self.contentView.superview];
    [appDelegate.window addSubview:self.contentView];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.contentView.frame = appDelegate.window.bounds;
    } completion:^(BOOL finished) {
        self.contentView.frame = self.bounds;
        [self addSubview:self.contentView];
        
        completionHandler();
    }];
    
    self.imageView.defaultImage = self.imageView.image;
    [self.imageView loadImageWithPath:self.movie.posterPath andWidth:500 completion:^(BOOL didLoadImage) {}];
}

- (void)prepareForShrink {
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    self.contentView.frame = appDelegate.window.bounds;
    [appDelegate.window addSubview:self.contentView];
}

- (void)animateShrinkWithCompletion:(void (^)(void))completionHandler {
    
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    [self prepareForShrink];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.contentView.frame = [appDelegate.window convertRect:self.frame fromView:self.superview];
    } completion:^(BOOL finished) {
        self.contentView.frame = self.bounds;
        [self addSubview:self.contentView];
        
        completionHandler();
    }];
    
    [self.imageView loadImageWithPath:self.movie.posterPath andWidth:185 completion:^(BOOL didLoadImage) {}];
}

@end
