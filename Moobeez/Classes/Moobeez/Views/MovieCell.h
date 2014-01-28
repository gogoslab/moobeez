//
//  MovieCell.h
//  Moobeez
//
//  Created by Radu Banea on 25/01/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TmdbMovie;
@class MoviePosterView;

@interface MovieCell : UITableViewCell

@property (strong, nonatomic) TmdbMovie* movie;

@property (weak, nonatomic) IBOutlet MoviePosterView *posterView;

@end
