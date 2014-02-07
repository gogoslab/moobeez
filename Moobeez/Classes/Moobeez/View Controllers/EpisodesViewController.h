//
//  EpisodesViewController.h
//  Moobeez
//
//  Created by Radu Banea on 06/02/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "ViewController.h"

@class Teebee;
@class TmdbTvSeason;

@interface EpisodesViewController : ViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) Teebee* teebee;
@property (weak, nonatomic) TmdbTvSeason* season;

@end
