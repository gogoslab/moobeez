//
//  MovieCell.m
//  Moobeez
//
//  Created by Radu Banea on 25/01/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "MovieCell.h"
#import "Moobeez.h"

@interface MovieCell ()

@property (weak, nonatomic) IBOutlet ImageView *posterImageView;

@property (weak, nonatomic) IBOutlet UILabel *detailsLabel;

@end

@implementation MovieCell

- (void)setMovie:(TmdbMovie *)movie {
    _movie = movie;
    
    self.posterView.movie = movie;
    self.detailsLabel.text = movie.name;

}

@end
