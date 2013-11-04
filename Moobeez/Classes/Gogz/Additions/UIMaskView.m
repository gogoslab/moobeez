//
//  UIMaskView.m
//  Moobeez
//
//  Created by Radu Banea on 04/11/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "UIMaskView.h"

@implementation UIMaskView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextClipToMask(context, [self bounds], [self.maskImage CGImage]);
    [super drawRect:rect]; // or draw your color manually
    CGContextRestoreGState(context);
}

@end
