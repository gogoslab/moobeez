//
//  ToolboxView.m
//  Moobeez
//
//  Created by Radu Banea on 10/23/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "ToolboxView.h"
#import "Moobeez.h"

#define MIN_TOOLBOX_HEIGHT 49

@interface ToolboxView ()

@property (weak, nonatomic) IBOutlet UIImageView *toolboxHandlerImageView;

@property (readwrite, nonatomic) CGFloat toolboxStartPoint;
@property (readwrite, nonatomic) CGFloat delta;

@end

@implementation ToolboxView

- (IBAction)toolboxDidPan:(id)sender {
    
    UIPanGestureRecognizer* gesture = (UIPanGestureRecognizer*) sender;
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            self.toolboxStartPoint = [gesture translationInView:self.superview].y;
            break;
        case UIGestureRecognizerStateChanged:
        {
            self.toolboxHandlerImageView.image = [UIImage imageNamed:@"toolbox_line.png"];
            
            int point = [gesture translationInView:self.superview].y;
            
            int toolboxViewY = self.y;
            toolboxViewY += point - self.toolboxStartPoint;
            
            toolboxViewY = MAX(toolboxViewY, self.minToolboxY);
            toolboxViewY = MIN(toolboxViewY, self.maxToolboxY);
            
            self.delta = toolboxViewY - self.y;
            self.toolboxStartPoint += self.delta;
            
            [UIView animateWithDuration:0.05 animations:^{
                self.y = toolboxViewY;
            }];
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            if (abs(self.delta) > 1) {
                if (self.delta > 0) {
                    [self hideFullToolbox];
                }
                else if (self.delta < 0) {
                    [self showFullToolbox];
                }
            }
            else {
                
                CGFloat position = (self.y - self.minToolboxY) / (self.maxToolboxY - self.minToolboxY);
                
                if (position > 0.5) {
                    [self hideFullToolbox];
                }
                else {
                    [self showFullToolbox];
                }
            }
        }
            break;
        default:
            break;
    }
}

- (void)showFullToolbox {
    
    CGFloat duration = 0.32 * (self.y - self.minToolboxY) / 216;
    
    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.y = self.minToolboxY;
    } completion:^(BOOL finished) {
        self.toolboxHandlerImageView.image = [UIImage imageNamed:@"toolbox_down_arrow.png"];
    }];
    
}

- (void)hideFullToolbox {
    
    CGFloat duration = 0.32 * (self.maxToolboxY - self.y) / 216;

    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.y = self.maxToolboxY;
    } completion:^(BOOL finished) {
        self.toolboxHandlerImageView.image = [UIImage imageNamed:@"toolbox_up_arrow.png"];
    }];
    
}

- (CGFloat)minToolboxY {
    return self.superview.height - self.height;
}

- (CGFloat)maxToolboxY {
    return self.superview.height - MIN_TOOLBOX_HEIGHT;
}

@end
