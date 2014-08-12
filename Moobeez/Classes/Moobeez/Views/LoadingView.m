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

@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@end

@implementation LoadingView

static LoadingView* loadingView;

+ (void)showLoadingViewWithContent:(UIView*)contentView {
    
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    if (!loadingView) {
        loadingView = [[NSBundle mainBundle] loadNibNamed:@"LoadingView" owner:self options:nil][0];
    }
    
    [appDelegate.window addSubview:loadingView];
    
    loadingView.alpha = 0.0;
    
    [UIView animateWithDuration:0.3 animations:^{
        loadingView.alpha = 1.0;
    }];
    
    loadingView.contentView = contentView;
    if (contentView) {
        [loadingView addSubview:loadingView.contentView];
        [loadingView.activityIndicatorView removeFromSuperview];
    }
}

+ (void)hideLoadingView {
    
    loadingView.alpha = 1.0;
    
    [UIView animateWithDuration:0.3 animations:^{
        loadingView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [loadingView removeFromSuperview];
        [loadingView.contentView removeFromSuperview];
    }];
}


@end
