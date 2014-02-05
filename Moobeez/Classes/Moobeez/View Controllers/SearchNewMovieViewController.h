//
//  SearchNewMovieViewController.h
//  Moobeez
//
//  Created by Radu Banea on 01/11/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "ViewController.h"

@class TmdbMovie;

typedef void (^SelectMovieHandler) (TmdbMovie* movie);

@interface SearchNewMovieViewController : ViewController

@property (copy, nonatomic) SelectMovieHandler selectHandler;

- (void)prepareBlurInView:(UIView*)view;

@end
