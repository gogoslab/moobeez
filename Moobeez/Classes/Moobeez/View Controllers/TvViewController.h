//
//  TvViewController.h
//  Moobeez
//
//  Created by Radu Banea on 02/01/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "ViewController.h"
#import "Constants.h"

@class Moobee;
@class TmdbMovie;

@interface TvViewController : ViewController

@property (strong, nonatomic) Moobee* moobee;
@property (strong, nonatomic) TmdbMovie* tmdbMovie;

@property (copy, nonatomic) EmptyHandler closeHandler;

@end
