//
//  FriendCell.h
//  Moobeez
//
//  Created by Radu Banea on 04/09/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ImageView;

@interface FriendCell : UITableViewCell

@property (weak, nonatomic) IBOutlet ImageView *pictureImageView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UIImageView *checkmarkImageView;
@end
