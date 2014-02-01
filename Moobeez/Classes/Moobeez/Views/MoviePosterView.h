//
//  MoviePosterView.h
//  Moobeez
//
//  Created by Radu Banea on 22/01/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TmdbMovie.h"

@interface MoviePosterView : UIView

@property (strong, nonatomic) NSObject* movie;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

+ (CGFloat)height;

- (void)animateGrowWithCompletion:(void (^)(void))completionHandler;
- (void)prepareForShrink;
- (void)animateShrinkWithCompletion:(void (^)(void))completionHandler;

@end
