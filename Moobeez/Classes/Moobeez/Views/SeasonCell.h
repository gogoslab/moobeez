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

@property (weak, nonatomic) TmdbTvSeason* season;
@property (weak, nonatomic) Teebee* teebee;
@property (strong, nonatomic) NSNumber* numberOfEpisodesWatched;

@property (readwrite, nonatomic) BOOL allEpisodes;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
