//
//  StarsView.m
//  Moobeez
//
//  Created by Radu Banea on 10/23/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "StarsView.h"
#import "Moobeez.h"

#define MAX_RATING 5

@interface StarsView ()

@property (weak, nonatomic) IBOutlet UIImageView* emptyStarsImageView;
@property (weak, nonatomic) IBOutlet UIImageView* fullStarsImageView;

@end

@implementation StarsView

- (void)awakeFromNib {
    _rating = MAX_RATING;
}

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
            _rating = self.ratingInPixels / (self.emptyStarsImageView.width + self.fullStarsImageView.width) * MAX_RATING;
            self.updateHandler();
        }
            break;
        default:
            break;
    }
    
}

- (void)setRating:(CGFloat)rating {

    if (_rating > 0) {
        self.ratingInPixels = self.fullStarsImageView.width * rating / _rating;
    }
    else {
        self.ratingInPixels = self.emptyStarsImageView.width * rating / MAX_RATING;
    }

    _rating = rating;
}

- (void)setRatingInPixels:(CGFloat)ratingInPixels {
    _ratingInPixels = ratingInPixels;
    
    self.fullStarsImageView.width = ratingInPixels;
    int right = self.emptyStarsImageView.width + self.emptyStarsImageView.x;
    self.emptyStarsImageView.x = self.fullStarsImageView.x + self.fullStarsImageView.width;
    self.emptyStarsImageView.width = right - self.emptyStarsImageView.x;
}

@end
