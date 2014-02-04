//
//  TvViewController.h
//  Moobeez
//
//  Created by Radu Banea on 02/01/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "ViewController.h"
#import "Constants.h"

@class Teebee;
@class TmdbTV;

@interface TvViewController : ViewController

@property (strong, nonatomic) Teebee* teebee;
@property (strong, nonatomic) TmdbTV* tmdbTv;

@property (copy, nonatomic) EmptyHandler closeHandler;

@end
