//
//  BeeCell.h
//  Moobeez
//
//  Created by Radu Banea on 10/14/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Bee;

@interface BeeCell : UICollectionViewCell

@property (weak, nonatomic) Bee* bee;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (void)animateGrowWithCompletion:(void (^)(void))completionHandler;
- (void)prepareForShrink;
- (void)animateShrinkWithCompletion:(void (^)(void))completionHandler;

+ (CGFloat)cellHeight;

@end
