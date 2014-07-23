//
//  SearchResultCell.m
//  Moobeez
//
//  Created by Radu Banea on 01/11/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "SearchResultCell.h"
#import "Moobeez.h"

@interface SearchResultCell ()

@property (weak, nonatomic) IBOutlet ImageView *posterImageView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *detailsLabel;

@end

@implementation SearchResultCell

- (void)awakeFromNib {
    self.posterImageView.loadSyncronized = YES;
}

- (void)setTmdbMovie:(TmdbMovie *)tmdbMovie {
    _tmdbMovie = tmdbMovie;
    
    [self.posterImageView loadImageWithPath:tmdbMovie.posterPath andWidth:92 completion:^(BOOL didLoadImage) {}];
    self.titleLabel.text = tmdbMovie.name;
    self.detailsLabel.text = [[NSDateFormatter dateFormatterWithFormat:@"dd MMM yyyy"] stringFromDate:tmdbMovie.releaseDate];
    
    self.detailsLabel.hidden = (self.detailsLabel.text.length == 0);
}

- (void)setTmdbPerson:(TmdbPerson *)tmdbPerson {
    _tmdbPerson = tmdbPerson;
    
    [self.posterImageView loadImageWithPath:tmdbPerson.profilePath andWidth:185 completion:^(BOOL didLoadImage) {}];
    self.titleLabel.text = tmdbPerson.name;
    self.detailsLabel.text = tmdbPerson.overview;
    
    self.detailsLabel.hidden = (self.detailsLabel.text.length == 0);
}

- (void)setTmdbTv:(TmdbTV *)tmdbTv {
    _tmdbTv = tmdbTv;
    
    [self.posterImageView loadImageWithPath:tmdbTv.posterPath andWidth:92 completion:^(BOOL didLoadImage) {}];
    self.titleLabel.text = tmdbTv.name;
    self.detailsLabel.text = [[NSDateFormatter dateFormatterWithFormat:@"dd MMM yyyy"] stringFromDate:tmdbTv.releaseDate];
    
    self.detailsLabel.hidden = (self.detailsLabel.text.length == 0);
}


@end
