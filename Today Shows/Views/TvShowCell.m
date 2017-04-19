//
//  TvShowCell.m
//  Moobeez
//
//  Created by Radu Banea on 06/06/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "TvShowCell.h"

@implementation TvShowCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    
    [super awakeFromNib];
    
    NSBundle* bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"MovieButtonsBlack" ofType:@"bundle"]];
    
    [self.watchedButton setBackgroundImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"button_watched_show@2x" ofType:@"png"]] forState:UIControlStateNormal];
    [self.watchedButton setBackgroundImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"button_watched_show_selected@2x" ofType:@"png"]] forState:UIControlStateSelected];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setTvShowDictionary:(NSMutableDictionary *)tvShowDictionary {
    _tvShowDictionary = tvShowDictionary;
    
    self.nameLabel.text = tvShowDictionary[@"name"];
    
    self.seasonLabel.text = [NSString stringWithFormat:@"Season %d", [tvShowDictionary[@"seasonNumber"] intValue]];
    self.episodeLabel.text = [NSString stringWithFormat:@"Episode %d", [tvShowDictionary[@"episodeNumber"] intValue]];
    
    NSURL *imageURL = [NSURL URLWithString:tvShowDictionary[@"posterFullPath"]];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Update the UI
            self.posterImageView.image = [UIImage imageWithData:imageData];
        });
    });
}

- (IBAction)watchButtonPressed:(id)sender {
    
    if ([self.parentTableView.delegate respondsToSelector:@selector(tableView:accessoryButtonTappedForRowWithIndexPath:)]) {
        [self.parentTableView.delegate tableView:self.parentTableView accessoryButtonTappedForRowWithIndexPath:[self.parentTableView indexPathForCell:self]];
    }
}

@end
