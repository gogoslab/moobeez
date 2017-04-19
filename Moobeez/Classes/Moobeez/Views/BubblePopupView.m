//
//  BubblePopupView.m
//  Moobeez
//
//  Created by Radu Banea on 05/11/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "BubblePopupView.h"
#import "Moobeez.h"

@interface BubblePopupView ()

@property (strong, nonatomic) CAShapeLayer* leftPathLayer;
@property (strong, nonatomic) CAShapeLayer* rightPathLayer;
@property (strong, nonatomic) CAShapeLayer* fullPathLayer;

@property (readwrite, nonatomic) NSInteger playingAnimationsCount;

@end

@implementation BubblePopupView

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)startAnimation {
    
    CGColorRef color = [[UIColor colorWithWhite:0.95 alpha:0.85] CGColor];
    
    self.sourceButton.hidden = YES;
    
    [self.leftPathLayer removeFromSuperlayer];
    [self.rightPathLayer removeFromSuperlayer];
    [self.fullPathLayer removeFromSuperlayer];
    
    
    CGPathRef leftPath = [self createLeftPath];
    
    self.leftPathLayer = [[CAShapeLayer alloc] init];
    self.leftPathLayer.path = leftPath;
    self.leftPathLayer.fillColor = [[UIColor clearColor] CGColor];
    self.leftPathLayer.strokeColor = color;
    self.leftPathLayer.lineWidth = 1.0;
    
    [self.layer addSublayer:self.leftPathLayer];
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 0.5;
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    pathAnimation.delegate = self;
    [self.leftPathLayer addAnimation:pathAnimation forKey:@"strokeEndAnimation"];
    
    CGPathRef rightPath = [self createRightPath];
    
    self.rightPathLayer = [[CAShapeLayer alloc] init];
    self.rightPathLayer.path = rightPath;
    self.rightPathLayer.fillColor = [[UIColor clearColor] CGColor];
    self.rightPathLayer.strokeColor = color;
    self.rightPathLayer.lineWidth = 1.0;

    [self.layer addSublayer:self.rightPathLayer];
    
    pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 0.5;
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    pathAnimation.delegate = self;
    [self.rightPathLayer addAnimation:pathAnimation forKey:@"strokeEndAnimation"];
    
    
    CGMutablePathRef fullPath = [self createFullPath];
    
    self.fullPathLayer = [[CAShapeLayer alloc] init];
    self.fullPathLayer.path = fullPath;
    self.fullPathLayer.fillColor = color;
    self.fullPathLayer.strokeColor = [[UIColor clearColor] CGColor];
    
    self.playingAnimationsCount = 2;
}

- (CGMutablePathRef)createLeftPath {
    
    CGMutablePathRef leftPath = CGPathCreateMutable();
    
    CGPathMoveToPoint(leftPath, nil, self.sourceButton.center.x, self.sourceButton.bottom);
    
    CGPoint fromPoint = CGPointMake(self.sourceButton.center.x, self.sourceButton.bottom);
    CGPoint toPoint = CGPointMake(self.sourceButton.x, self.sourceButton.center.y);
    
    [self addQuarterCircleCurveToPath:leftPath from:fromPoint to:toPoint convex:YES];
    
    fromPoint = toPoint;
    toPoint = CGPointMake(MAX(0, fromPoint.x - self.sourceButton.width / 2), fromPoint.y - self.sourceButton.height / 2);
    
    [self addQuarterCircleCurveToPath:leftPath from:fromPoint to:toPoint convex:NO];
    
    if (toPoint.x > self.sourceButton.width / 2) {
        fromPoint = toPoint;
        toPoint = CGPointMake(self.sourceButton.width / 2, fromPoint.y);
        
        CGPathAddLineToPoint(leftPath, nil, toPoint.x, toPoint.y);
    }
    
    fromPoint = toPoint;
    toPoint = CGPointMake(0, toPoint.y - self.sourceButton.height / 2);
    [self addQuarterCircleCurveToPath:leftPath from:fromPoint to:toPoint convex:YES];
    
    fromPoint = toPoint;
    toPoint = CGPointMake(0, self.sourceButton.height / 2);
    CGPathAddLineToPoint(leftPath, nil, toPoint.x, toPoint.y);
    
    fromPoint = toPoint;
    toPoint = CGPointMake(self.sourceButton.width / 2, 0);
    [self addQuarterCircleCurveToPath:leftPath from:fromPoint to:toPoint convex:NO];
    
    fromPoint = toPoint;
    toPoint = CGPointMake(self.width - self.sourceButton.width / 2, 0);
    CGPathAddLineToPoint(leftPath, nil, toPoint.x, toPoint.y);
    
    return leftPath;
}

- (CGMutablePathRef)createRightPath {
    
    CGMutablePathRef rightPath = CGPathCreateMutable();
    
    CGPathMoveToPoint(rightPath, nil, self.sourceButton.center.x, self.sourceButton.bottom);
    
    CGPoint fromPoint = CGPointMake(self.sourceButton.center.x, self.sourceButton.bottom);
    CGPoint toPoint = CGPointMake(self.sourceButton.right, self.sourceButton.center.y);
    
    [self addQuarterCircleCurveToPath:rightPath from:fromPoint to:toPoint convex:YES];
    
    fromPoint = toPoint;
    toPoint = CGPointMake(MIN(self.width - self.sourceButton.width / 2, fromPoint.x + self.sourceButton.width / 2), fromPoint.y - self.sourceButton.height / 2);
    
    [self addQuarterCircleCurveToPath:rightPath from:fromPoint to:toPoint convex:NO];
    
    if (toPoint.x < self.width - self.sourceButton.width / 2) {
        fromPoint = toPoint;
        toPoint = CGPointMake(self.width - self.sourceButton.width / 2, fromPoint.y);
        
        CGPathAddLineToPoint(rightPath, nil, toPoint.x, toPoint.y);
    }
    
    fromPoint = toPoint;
    toPoint = CGPointMake(self.width, toPoint.y - self.sourceButton.height / 2);
    [self addQuarterCircleCurveToPath:rightPath from:fromPoint to:toPoint convex:YES];
    
    fromPoint = toPoint;
    toPoint = CGPointMake(self.width, self.sourceButton.height / 2);
    CGPathAddLineToPoint(rightPath, nil, toPoint.x, toPoint.y);
    
    fromPoint = toPoint;
    toPoint = CGPointMake(self.width - self.sourceButton.width / 2, 0);
    [self addQuarterCircleCurveToPath:rightPath from:fromPoint to:toPoint convex:NO];
    
    return rightPath;
}

- (CGMutablePathRef)createFullPath {
    
    CGMutablePathRef fullPath = [self createLeftPath];
    
    CGPoint fromPoint = CGPointMake(self.width - self.sourceButton.width / 2, 0);
    CGPoint toPoint = CGPointMake(self.width, self.sourceButton.height / 2);
    
    [self addQuarterCircleCurveToPath:fullPath from:fromPoint to:toPoint convex:YES];
    
    fromPoint = toPoint;
    toPoint = CGPointMake(self.width, self.sourceButton.y - self.sourceButton.height / 2);
    CGPathAddLineToPoint(fullPath, nil, toPoint.x, toPoint.y);
    
    fromPoint = toPoint;
    toPoint = CGPointMake(MIN(self.width, MAX(self.width - self.sourceButton.width / 2, self.sourceButton.right + self.sourceButton.width / 2)) , self.sourceButton.y);
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
    toPoint = CGPointMake(self.sourceButton.center.x, self.sourceButton.bottom);
    [self addQuarterCircleCurveToPath:fullPath from:fromPoint to:toPoint convex:NO];
    
    return fullPath;
}

- (void)addQuarterCircleCurveToPath:(CGMutablePathRef)path from:(CGPoint)startPoint to:(CGPoint)endPoint convex:(BOOL)convex {
    
    CGFloat kappa = 0.5522847498;
    CGFloat firstKappa = (convex ? kappa : 0.0);
    CGFloat secondKappa = (convex ? 0.0 : kappa);
    
    CGPoint cp1 = CGPointMake(startPoint.x + (endPoint.x - startPoint.x) * firstKappa, startPoint.y + (endPoint.y - startPoint.y) * secondKappa);
    CGPoint cp2 = CGPointMake(endPoint.x - (endPoint.x - startPoint.x) * secondKappa, endPoint.y - (endPoint.y - startPoint.y) * firstKappa);
    
    CGPathAddCurveToPoint(path, nil, cp1.x, cp1.y, cp2.x, cp2.y, endPoint.x, endPoint.y);
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (--self.playingAnimationsCount == 0) {
        [self.layer insertSublayer:self.fullPathLayer atIndex:0];
        [self.leftPathLayer removeFromSuperlayer];
        [self.rightPathLayer removeFromSuperlayer];
        
        self.sourceButton.hidden = NO;
        
        self.animationCompletionHandler();
    }
}


@end
