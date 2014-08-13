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
@property (weak, nonatomic) IBOutlet StarsView *starsView;

@end

@implementation TimelineItemCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setItem:(TimelineItem*)item {
    _item = item;
    
    if (item.backdropPath) {
        [self.backdropImageView loadImageWithPath:item.backdropPath andWidth:780 completion:^(BOOL didLoadImage) {
            
        }];
    }
    else {
        self.backdropImageView.image = nil;
    }
    
    self.titleLabel.text = item.name;
    
    if (!item.isMovie) {
        self.subtitleLabel.text = [NSString stringWithFormat:@"Season %ld Episode %ld", (long)item.season, (long)item.episode];
    }
    else {
        self.subtitleLabel.hidden = YES;
        
        if (item.rating >= 0) {
            self.starsView.hidden = NO;
            self.starsView.rating = item.rating;
        }
        else {
            self.starsView.hidden = YES;
        }
    }
}

@end
