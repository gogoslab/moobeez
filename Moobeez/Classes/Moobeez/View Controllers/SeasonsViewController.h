//
//  SeasonsViewController.h
//  Moobeez
//
//  Created by Radu Banea on 06/02/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "ViewController.h"

@class Teebee;
@class TmdbTV;

@interface SeasonsViewController : ViewController

@property (strong, nonatomic) Teebee* teebee;
@property (strong, nonatomic) TmdbTV* tv;

- (void)reloadData;

@end
