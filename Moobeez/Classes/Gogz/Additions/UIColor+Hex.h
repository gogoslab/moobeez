//
//  UIColor+Hex.h
//  Gogz
//
//  Created by Radu Banea on 10/11/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Hex)

+ (UIColor*)colorWithHexString:(NSString*)hex;
+ (UIColor*)colorWithHexString:(NSString*)hex alpha:(CGFloat)alpha;

@end
