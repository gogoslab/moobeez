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

@property (weak, nonatomic) IBOutlet ImageView *posterImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation MoobeeCell

- (void)setMoobee:(Moobee *)moobee {
    _moobee = moobee;
    
    self.nameLabel.text = moobee.name;
    
    self.posterImageView.loadSyncronized = YES;
    [self.posterImageView loadImageWithPath:moobee.posterPath andWidth:154];
}

@end
