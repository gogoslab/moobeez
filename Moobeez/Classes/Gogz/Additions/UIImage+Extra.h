//
//  UIImage+Extra.h
//  Gogz
//
//  Created by Radu Banea on 10/11/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef unsigned char byte;

typedef struct RGBAPixel {
    byte red;
    byte green;
    byte blue;
    byte alpha;
} RGBAPixel;

@interface UIImage (Extra)

- (UIImage *)scaledToSize:(CGSize)newSize;
- (RGBAPixel*)bitmap;
- (CGFloat)luminosity;
- (CGFloat)bottomHalfLuminosity;

@end
