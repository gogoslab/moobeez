//
//  TvWatchedViewController.h
//  Moobeez
//
//  Created by Radu Banea on 05/11/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "ViewController.h"

@class Teebee;
@class TmdbTV;

@interface TvWatchedViewController : ViewController

@property (strong, nonatomic) UIView* sourceButton;
@property (strong, nonatomic) Teebee* teebee;
@property (strong, nonatomic) TmdbTV* tv;


- (void)startAnimation;

@end
