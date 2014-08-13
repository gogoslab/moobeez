//
//  DashboardMovieCell.m
//  Moobeez
//
//  Created by Radu Banea on 02/07/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "DashboardMovieCell.h"
#import "Moobeez.h"
#import "ImageView.h"

@interface DashboardMovieCell ()

@property (weak, nonatomic) IBOutlet ImageView *posterImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailsLabel;

@end

@implementation DashboardMovieCell

- (void)awakeFromNib
{
    // Initialization code
    
    NSBundle* bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"MovieButtonsWhite" ofType:@"bundle"]];
    
    [self.watchedButton setBackgroundImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"button_watched_show@2x" ofType:@"png"]] forState:UIControlStateNormal];
    [self.watchedButton setBackgroundImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"button_watched_show_selected@2x" ofType:@"png"]] forState:UIControlStateSelected];
    
}

- (void)setMoobee:(Moobee *)moobee {

    _moobee = moobee;
    
    self.nameLabel.text = moobee.name;
    
    [self.posterImageView loadImageWithPath:moobee.posterPath andWidth:92 completion:^(BOOL didLoadImage) {
        
    }];    
}

- (IBAction)watchButtonPressed:(id)sender {
    
    if ([self.parentTableView.delegate respondsToSelector:@selector(tableView:accessoryButtonTappedForRowWithIndexPath:)]) {
        [self.parentTableView.delegate tableView:self.parentTableView accessoryButtonTappedForRowWithIndexPath:[self.parentTableView indexPathForCell:self]];
    }
}
@end
