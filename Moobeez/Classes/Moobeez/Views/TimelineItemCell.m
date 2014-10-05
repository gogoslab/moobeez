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
@property (weak, nonatomic) IBOutlet UIImageView *shadowImageView;
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
        [self.backdropImageView loadBackdropWithPath:item.backdropPath completion:^(BOOL didLoadImage) {
            
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
    
    [self setNeedsLayout];
    [self layoutIfNeeded];

}

- (void)layoutSubviews {
    
    self.backdropImageView.frame = self.bounds;
    self.shadowImageView.width = self.width;
    self.shadowImageView.y = self.height - self.shadowImageView.height;
    
    self.titleLabel.center = CGPointMake(self.width / 2, self.titleLabel.center.y);
    self.subtitleLabel.center = CGPointMake(self.width / 2, self.subtitleLabel.center.y);
    self.starsView.center = CGPointMake(self.width / 2, self.starsView.center.y);

}

@end
