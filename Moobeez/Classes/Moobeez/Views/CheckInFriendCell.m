//
//  CheckInFriendCell.m
//  Moobeez
//
//  Created by Radu Banea on 05/09/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "CheckInFriendCell.h"
#import "Moobeez.h"

@implementation CheckInFriendCell

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    self.pictureImageView.layer.cornerRadius = self.pictureImageView.frame.size.height / 2;
}

@end
