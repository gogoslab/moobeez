//
//  CheckInPlaceCell.h
//  Moobeez
//
//  Created by Radu Banea on 21/07/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ImageView;

@interface CheckInPlaceCell : UITableViewCell

@property (weak, nonatomic) IBOutlet ImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *checkmarkImageView;

@end
