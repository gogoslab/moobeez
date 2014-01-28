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
@property (weak, nonatomic) IBOutlet ImageView *backdropImageView;

@property (weak, nonatomic) IBOutlet UILabel *detailsLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (readwrite, nonatomic) CGRect initialFrame;

@end

@implementation MovieCell

- (void)awakeFromNib {
    
    self.initialFrame = self.detailsLabel.frame;
    
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
    tapGesture.numberOfTapsRequired = 1;
    [self.contentView addGestureRecognizer:tapGesture];
}

- (void)setMovie:(TmdbMovie *)movie {
    _movie = movie;
    
    self.posterView.movie = movie;
    
    self.detailsLabel.text = movie.name;
    self.detailsLabel.frame = self.initialFrame;
    
    [self.detailsLabel sizeToFit];
    
    self.dateLabel.text = [[NSDateFormatter dateFormatterWithFormat:@"dd MMMM yyyy"] stringFromDate:self.movie.releaseDate];

    [self.backdropImageView loadImageWithPath:self.movie.backdropPath andWidth:300 completion:^(BOOL didLoadImage) {
        
    }];
}

- (IBAction)collapseButtonPressed:(id)sender {
    if ([self.parentTableView.delegate respondsToSelector:@selector(tableView:accessoryButtonTappedForRowWithIndexPath:)]) {
        [self.parentTableView.delegate tableView:self.parentTableView accessoryButtonTappedForRowWithIndexPath:[self.parentTableView indexPathForCell:self]];
    }
}

- (IBAction)didTap:(id)sender {
    
    NSIndexPath* indexPath = [self.parentTableView indexPathForCell:self];
    
    MoviesHeaderView* headerView = (MoviesHeaderView*) [self.parentTableView.delegate tableView:self.parentTableView viewForHeaderInSection:indexPath.section];
    
    if (CGRectContainsPoint(headerView.collapseButton.frame, [(UITapGestureRecognizer*) sender locationInView:headerView])) {
        [self collapseButtonPressed:nil];
    }
    else {
        [self.parentTableView.delegate tableView:self.parentTableView didSelectRowAtIndexPath:indexPath];
    }
}


@end
