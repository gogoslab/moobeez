//
//  StarsView.m
//  Moobeez
//
//  Created by Radu Banea on 10/23/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "StarsView.h"
#import "Moobeez.h"

@interface StarsView ()

@property (weak, nonatomic) IBOutlet UIImageView* emptyStarsImageView;
@property (weak, nonatomic) IBOutlet UIImageView* fullStarsImageView;

@end

@implementation StarsView


- (IBAction)starsViewDidPan:(id)sender {
    
    UIPanGestureRecognizer* gesture = (UIPanGestureRecognizer*) sender;
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            break;
        case UIGestureRecognizerStateChanged:
        {
            int point = [gesture locationInView:self].x;
            
            point = MIN(point, self.width);
            point = MAX(point, 0);
            
            point = roundf((float) point / (self.width / 10)) * (self.width / 10);
            
            self.ratingInPixels = point;
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
        }
            break;
        default:
            break;
    }
    
}

- (void)setRating:(CGFloat)rating {
    _rating = rating;
    
    self.ratingInPixels = self.width * rating / 5;
}

- (void)setRatingInPixels:(CGFloat)ratingInPixels {
    _ratingInPixels = ratingInPixels;
    
    self.fullStarsImageView.width = ratingInPixels;
    self.emptyStarsImageView.width = self.width - ratingInPixels;
    self.emptyStarsImageView.x = ratingInPixels;
}

@end
