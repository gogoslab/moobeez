//
//  LoadingView.m
//  Moobeez
//
//  Created by Radu Banea on 07/02/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "LoadingView.h"
#import "Moobeez.h"

@interface LoadingView ()

@property (weak, nonatomic) IBOutlet UIImageView *blurView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@end

@implementation LoadingView

static LoadingView* loadingView;

+ (void)showLoadingViewWithContent:(UIView*)contentView {
    
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    if (!loadingView) {
        loadingView = [[NSBundle mainBundle] loadNibNamed:@"LoadingView" owner:self options:nil][0];
    }
    
    CGSize size = loadingView.blurView.frame.size;
    
    CGFloat scale = 1;//[UIScreen mainScreen].scale;
    size.width *= scale;
    size.height *= scale;
    
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextScaleCTM(ctx, scale, scale);
    
    [appDelegate.window.layer renderInContext:ctx];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    GPUImageiOSBlurFilter *filter = [[GPUImageiOSBlurFilter alloc] init];
    filter.blurRadiusInPixels = [UIScreen mainScreen].scale * 2;
    loadingView.blurView.image = [filter imageByFilteringImage:image];
    
    loadingView.blurView.contentMode = UIViewContentModeCenter;
    
    [appDelegate.window addSubview:loadingView];
    
    loadingView.alpha = 0.0;
    
    [UIView animateWithDuration:0.3 animations:^{
        loadingView.alpha = 1.0;
    }];
    
    loadingView.contentView = contentView;
    if (contentView) {
        [loadingView addSubview:loadingView.contentView];
    }
}

+ (void)hideLoadingView {
    
    loadingView.alpha = 1.0;
    
    [UIView animateWithDuration:0.3 animations:^{
        loadingView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [loadingView removeFromSuperview];
        loadingView.blurView.image = nil;
        [loadingView.contentView removeFromSuperview];
    }];
}


@end
