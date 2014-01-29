//
//  BubbleUpsideDownPopupView.m
//  Moobeez
//
//  Created by Radu Banea on 05/11/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "BubbleUpsideDownPopupView.h"
#import "Moobeez.h"

@interface BubbleUpsideDownPopupView ()

@property (strong, nonatomic) CAShapeLayer* fullPathLayer;

@end

@implementation BubbleUpsideDownPopupView

- (void)startAnimation {
    [super startAnimation];
    
    self.fullPathLayer.fillColor = [[UIColor colorWithWhite:0.95 alpha:0.2] CGColor];
    self.fullPathLayer.strokeColor = [[UIColor colorWithWhite:0.95 alpha:0.85] CGColor];
}

- (CGMutablePathRef)createLeftPath {
    
    CGMutablePathRef leftPath = CGPathCreateMutable();
    
    CGPathMoveToPoint(leftPath, nil, self.sourceButton.center.x, self.sourceButton.y);
    
    CGPoint fromPoint = CGPointMake(self.sourceButton.center.x, self.sourceButton.y);
    CGPoint toPoint = CGPointMake(self.sourceButton.x, self.sourceButton.center.y);
    
    [self addQuarterCircleCurveToPath:leftPath from:fromPoint to:toPoint convex:YES];
    
    fromPoint = toPoint;
    toPoint = CGPointMake(MAX(0, fromPoint.x - self.sourceButton.width / 2), fromPoint.y + self.sourceButton.height / 2);
    
    [self addQuarterCircleCurveToPath:leftPath from:fromPoint to:toPoint convex:NO];
    
    if (toPoint.x > self.sourceButton.width / 2) {
        fromPoint = toPoint;
        toPoint = CGPointMake(self.sourceButton.width / 2, fromPoint.y);
        
        CGPathAddLineToPoint(leftPath, nil, toPoint.x, toPoint.y);
    }
    
    fromPoint = toPoint;
    toPoint = CGPointMake(0, toPoint.y + self.sourceButton.height / 2);
    [self addQuarterCircleCurveToPath:leftPath from:fromPoint to:toPoint convex:YES];
    
    fromPoint = toPoint;
    toPoint = CGPointMake(0, self.height - self.sourceButton.height / 2);
    CGPathAddLineToPoint(leftPath, nil, toPoint.x, toPoint.y);
    
    fromPoint = toPoint;
    toPoint = CGPointMake(self.sourceButton.width / 2, self.height);
    [self addQuarterCircleCurveToPath:leftPath from:fromPoint to:toPoint convex:NO];
    
    fromPoint = toPoint;
    toPoint = CGPointMake(self.width - self.sourceButton.width / 2, self.height);
    CGPathAddLineToPoint(leftPath, nil, toPoint.x, toPoint.y);
    
    return leftPath;
}

- (CGMutablePathRef)createRightPath {
    
    CGMutablePathRef rightPath = CGPathCreateMutable();
    
    CGPathMoveToPoint(rightPath, nil, self.sourceButton.center.x, self.sourceButton.y);
    
    CGPoint fromPoint = CGPointMake(self.sourceButton.center.x, self.sourceButton.y);
    CGPoint toPoint = CGPointMake(self.sourceButton.right, self.sourceButton.center.y);
    
    [self addQuarterCircleCurveToPath:rightPath from:fromPoint to:toPoint convex:YES];
    
    fromPoint = toPoint;
    toPoint = CGPointMake(MIN(self.width, fromPoint.x + self.sourceButton.width / 2), fromPoint.y + self.sourceButton.height / 2);
    
    [self addQuarterCircleCurveToPath:rightPath from:fromPoint to:toPoint convex:NO];
    
    if (toPoint.x < self.width - self.sourceButton.width / 2) {
        fromPoint = toPoint;
        toPoint = CGPointMake(self.width - self.sourceButton.width / 2, fromPoint.y);
        
        CGPathAddLineToPoint(rightPath, nil, toPoint.x, toPoint.y);
    }
    
    fromPoint = toPoint;
    toPoint = CGPointMake(self.width, toPoint.y + self.sourceButton.height / 2);
    [self addQuarterCircleCurveToPath:rightPath from:fromPoint to:toPoint convex:YES];
    
    fromPoint = toPoint;
    toPoint = CGPointMake(self.width, self.height - self.sourceButton.height / 2);
    CGPathAddLineToPoint(rightPath, nil, toPoint.x, toPoint.y);
    
    fromPoint = toPoint;
    toPoint = CGPointMake(self.width - self.sourceButton.width / 2, self.height);
    [self addQuarterCircleCurveToPath:rightPath from:fromPoint to:toPoint convex:NO];
    
    return rightPath;
}

- (CGMutablePathRef)createFullPath {
    
    CGMutablePathRef fullPath = [self createLeftPath];
    
    CGPoint fromPoint = CGPointMake(self.width - self.sourceButton.width / 2, self.height);
    CGPoint toPoint = CGPointMake(self.width, self.height - self.sourceButton.height / 2);
    
    [self addQuarterCircleCurveToPath:fullPath from:fromPoint to:toPoint convex:YES];
    
    fromPoint = toPoint;
    toPoint = CGPointMake(self.width, self.sourceButton.bottom + self.sourceButton.height / 2);
    CGPathAddLineToPoint(fullPath, nil, toPoint.x, toPoint.y);
    
    fromPoint = toPoint;
    toPoint = CGPointMake(MIN(self.width, MAX(self.width - self.sourceButton.width / 2, self.sourceButton.right + self.sourceButton.width / 2)) , self.sourceButton.bottom);
    [self addQuarterCircleCurveToPath:fullPath from:fromPoint to:toPoint convex:NO];
    
    if (toPoint.x > self.sourceButton.right + self.sourceButton.width / 2) {
        fromPoint = toPoint;
        toPoint = CGPointMake(self.sourceButton.right + self.sourceButton.width / 2, fromPoint.y);
        CGPathAddLineToPoint(fullPath, nil, toPoint.x, toPoint.y);
    }
    
    fromPoint = toPoint;
    toPoint = CGPointMake(self.sourceButton.right, self.sourceButton.center.y);
    
    [self addQuarterCircleCurveToPath:fullPath from:fromPoint to:toPoint convex:YES];
    
    fromPoint = toPoint;
    toPoint = CGPointMake(self.sourceButton.center.x, self.sourceButton.y);
    [self addQuarterCircleCurveToPath:fullPath from:fromPoint to:toPoint convex:NO];
    
    return fullPath;
}

@end
