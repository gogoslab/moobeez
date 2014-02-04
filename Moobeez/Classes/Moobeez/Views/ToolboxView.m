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

- (void)addToSuperview:(UIView *)view {
    
    [self prepareBlurInView:view];
    
    [view addSubview:self];
    self.y = self.maxToolboxY;
    
    [view insertSubview:self.blurImageView belowSubview:self];
    self.blurImageView.y = self.y;
    self.blurImageView.height = view.height - self.blurImageView.y;
}

- (void)prepareBlurInView:(UIView*)view {
    
    CGSize size = view.bounds.size;
    
    CGFloat scale = 1;//[UIScreen mainScreen].scale;
    size.width *= scale;
    size.height *= scale;
    
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextScaleCTM(ctx, scale, scale);
    
    [view.layer renderInContext:ctx];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    GPUImageiOSBlurFilter *filter = [[GPUImageiOSBlurFilter alloc] init];
    filter.blurRadiusInPixels = [UIScreen mainScreen].scale * 4;
    self.blurImageView.image = [filter imageByFilteringImage:image];
    
    self.blurImageView.contentMode = UIViewContentModeBottom;
    
    CGFloat luminosity = [image bottomHalfLuminosity];
 
    self.isLightInterface = (luminosity <= 100);
}

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
                CGRect frame = self.blurImageView.frame;
                frame.origin.y = self.y;
                frame.size.height = self.superview.height - self.y;
                self.blurImageView.frame = frame;
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
    
    if ([self.delegate respondsToSelector:@selector(toolboxViewWillShow:)]) {
        [self.delegate toolboxViewWillShow:self];
    }
    
    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.y = self.minToolboxY;
        CGRect frame = self.blurImageView.frame;
        frame.origin.y = self.y;
        frame.size.height = self.superview.height - self.y;
        self.blurImageView.frame = frame;
    } completion:^(BOOL finished) {
        self.toolboxHandlerImageView.image = [UIImage imageNamed:@"toolbox_down_arrow.png"];
        
        self.isFullyDisplayed = YES;

        if ([self.delegate respondsToSelector:@selector(toolboxViewDidShow:)]) {
            [self.delegate toolboxViewDidShow:self];
        }
    }];
    
}

- (void)hideFullToolbox {
    
    CGFloat duration = 0.32 * (self.maxToolboxY - self.y) / 216;

    if ([self.delegate respondsToSelector:@selector(toolboxViewWillHide:)]) {
        [self.delegate toolboxViewWillHide:self];
    }
    
    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.y = self.maxToolboxY;
        CGRect frame = self.blurImageView.frame;
        frame.origin.y = self.y;
        frame.size.height = self.superview.height - self.y;
        self.blurImageView.frame = frame;

    } completion:^(BOOL finished) {
        self.toolboxHandlerImageView.image = [UIImage imageNamed:@"toolbox_up_arrow.png"];
        
        self.isFullyDisplayed = NO;
        
        if ([self.delegate respondsToSelector:@selector(toolboxViewDidHide:)]) {
            [self.delegate toolboxViewDidHide:self];
        }
    }];
    
}

- (CGFloat)minToolboxY {
    return self.superview.height - self.height;
}

- (CGFloat)maxToolboxY {
    return self.superview.height - MIN_TOOLBOX_HEIGHT;
}

@end
