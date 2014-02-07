//
//  SeasonCell.h
//  Moobeez
//
//  Created by Radu Banea on 06/02/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TmdbTvSeason;
@class Teebee;

@interface SeasonCell : UITableViewCell

@property (strong, nonatomic) TmdbTvSeason* season;
@property (strong, nonatomic) Teebee* teebee;
@property (strong, nonatomic) NSNumber* numberOfEpisodesWatched;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
