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

@property (weak, nonatomic) IBOutlet UIView *sourceButton;
@property (copy, nonatomic) EmptyHandler animationCompletionHandler;

- (void)startAnimation;

- (void)addQuarterCircleCurveToPath:(CGMutablePathRef)path from:(CGPoint)startPoint to:(CGPoint)endPoint convex:(BOOL)convex;

@end
