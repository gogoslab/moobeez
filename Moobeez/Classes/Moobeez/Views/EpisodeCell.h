//
//  EpisodeCell.h
//  Moobeez
//
//  Created by Radu Banea on 06/02/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TmdbTvEpisode;
@class Teebee;
@class TeebeeEpisode;

@interface EpisodeCell : UITableViewCell

@property (weak, nonatomic) TmdbTvEpisode* episode;
@property (weak, nonatomic) Teebee* teebee;
@property (weak, nonatomic) TeebeeEpisode* teebeeEpisode;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
