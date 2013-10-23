//
//  MovieViewController.h
//  Moobeez
//
//  Created by Radu Banea on 10/21/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "ViewController.h"
#import "Constants.h"

@class Moobee;
@class TmdbMovie;

@interface MovieViewController : ViewController

@property (strong, nonatomic) Moobee* moobee;
@property (strong, nonatomic) TmdbMovie* tmdbMovie;

@property (copy, nonatomic) EmptyHandler closeHandler;

@end
