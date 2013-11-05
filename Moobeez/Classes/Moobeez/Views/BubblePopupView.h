//
//  BubblePopupView.h
//  Moobeez
//
//  Created by Radu Banea on 05/11/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

@interface BubblePopupView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *sourceButton;
@property (copy, nonatomic) EmptyHandler animationCompletionHandler;

- (void)startAnimation;

@end
