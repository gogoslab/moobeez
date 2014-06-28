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
    
    NSBundle* bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"MovieButtonsWhite" ofType:@"bundle"]];
    
    [self.watchedButton setBackgroundImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"button_watched_show" ofType:@"png"]] forState:UIControlStateNormal];
    [self.watchedButton setBackgroundImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"button_watched_show_selected" ofType:@"png"]] forState:UIControlStateSelected];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setTvShowDictionary:(NSMutableDictionary *)tvShowDictionary {
    _tvShowDictionary = tvShowDictionary;
    
    self.nameLabel.text = tvShowDictionary[@"name"];
    
    self.detailsLabel.text = [NSString stringWithFormat:@"Season %d Episode %d", [tvShowDictionary[@"seasonNumber"] intValue], [tvShowDictionary[@"episodeNumber"] intValue]];
    
    NSURL *imageURL = [NSURL URLWithString:tvShowDictionary[@"posterPath"]];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Update the UI
            self.posterImageView.image = [UIImage imageWithData:imageData];
        });
    });
}

@end
