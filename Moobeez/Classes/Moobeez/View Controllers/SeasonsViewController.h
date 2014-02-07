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

@property (weak, nonatomic) Teebee* teebee;
@property (weak, nonatomic) TmdbTV* tv;

- (void)reloadData;

@end
