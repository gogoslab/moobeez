//
//  TimelineItemCell.m
//  Moobeez
//
//  Created by Radu Banea on 12/08/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "TimelineItemCell.h"
#import "Moobeez.h"

@interface TimelineItemCell ()

@property (weak, nonatomic) IBOutlet ImageView *backdropImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;

@end

@implementation TimelineItemCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setItem:(TimelineItem*)item {
    _item = item;
    
    [self.backdropImageView loadImageWithPath:item.backdropPath andWidth:300 completion:^(BOOL didLoadImage) {
        
    }];
    
    self.titleLabel.text = item.name;
    
    if (item.season != -1) {
        self.subtitleLabel.text = [NSString stringWithFormat:@"Season %ld Episode %ld", (long)item.season, (long)item.episode];
    }
    else {
        self.subtitleLabel.hidden = YES;
    }
}

@end
