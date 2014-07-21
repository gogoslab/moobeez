//
//  CheckInMovieCell.h
//  Moobeez
//
//  Created by Radu Banea on 21/07/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ImageView;

@interface CheckInMovieCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet ImageView *posterImageView;

@property (weak, nonatomic) IBOutlet UIImageView *checkmarkImageView;

@end
