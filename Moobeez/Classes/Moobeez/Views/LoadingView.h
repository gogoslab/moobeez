//
//  LoadingView.h
//  Moobeez
//
//  Created by Radu Banea on 07/02/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingView : UIView

+ (void)showLoadingViewWithContent:(UIView*)contentView;
+ (void)hideLoadingView;

@end
