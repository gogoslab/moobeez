//
//  MoobeeCell.m
//  Moobeez
//
//  Created by Radu Banea on 10/14/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "MoobeeCell.h"
#import "Moobeez.h"

@interface MoobeeCell ()

@property (weak, nonatomic) IBOutlet UIView* contentView;

@property (weak, nonatomic) IBOutlet ImageView *posterImageView;
@property (weak, nonatomic) IBOutlet UIImageView *emptyStarsImageView;
@property (weak, nonatomic) IBOutlet UIImageView *fullStarsImageView;
@property (weak, nonatomic) IBOutlet UIView *starsView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation MoobeeCell

- (void)setMoobee:(Moobee *)moobee {
    _moobee = moobee;
    
    self.nameLabel.text = moobee.name;
    
    self.fullStarsImageView.width = self.emptyStarsImageView.width * moobee.rating / 5;

    self.posterImageView.loadSyncronized = YES;
    [self.posterImageView loadImageWithPath:moobee.posterPath andWidth:154 completion:^(BOOL didLoadImage) {
        self.nameLabel.hidden = didLoadImage;
    }];
    
    self.starsView.hidden = (moobee.type != MoobeeSeenType);
}

- (void)drawRect:(CGRect)rect {
    
    self.fullStarsImageView.width = self.emptyStarsImageView.width * self.moobee.rating / 5;
    [super drawRect:rect];
}

@end
