//
//  UIImage+Extra.m
//  Gogz
//
//  Created by Radu Banea on 10/11/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "UIImage+Extra.h"

#define RGBA        4
#define RGBA_8_BIT  8

@implementation UIImage (Extra)

- (UIImage *)scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();    
    UIGraphicsEndImageContext();
    return newImage;
}

- (RGBAPixel*)bitmap {
    
    size_t bytesPerRow = self.size.width * RGBA;
    size_t byteCount = bytesPerRow * self.size.height;

    // Create RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    if (!colorSpace)
    {
        NSLog(@"Error allocating color space.");
        return nil;
    }
    
    RGBAPixel *pixelData = malloc(byteCount);
    
    if (!pixelData)
    {
        NSLog(@"Error allocating bitmap memory. Releasing color space.");
        CGColorSpaceRelease(colorSpace);
        
        return nil;
    }
    
    // Create the bitmap context.
    // Pre-multiplied RGBA, 8-bits per component.
    // The source image format will be converted to the format specified here by CGBitmapContextCreate.
    CGContextRef context = CGBitmapContextCreate(
                                           (void*)pixelData,
                                           self.size.width,
                                           self.size.height,
                                           RGBA_8_BIT,
                                           bytesPerRow,
                                           colorSpace,
                                           kCGImageAlphaPremultipliedLast
                                           );
    
    // Make sure we have our context
    if (!context)   {
        free(pixelData);
        NSLog(@"Context not created!");
    }
    
    // Draw the image to the bitmap context.
    // The memory allocated for the context for rendering will then contain the raw image pixelData in the specified color space.
    CGRect rect = { { 0 , 0 }, { self.size.width, self.size.height } };
    
    CGContextDrawImage( context, rect, self.CGImage );
    
    // Now we can get a pointer to the image pixelData associated with the bitmap context.
    pixelData = (RGBAPixel*) CGBitmapContextGetData(context);
    
    return pixelData;
}

- (CGFloat)luminosity {
    
    CGFloat luminosity = 0.0f;
    
    RGBAPixel* pixels = [self bitmap];
    
    for (int i = 0; i < self.size.width * self.size.height; ++i) {
        luminosity += pixels[i].red * 0.299 + pixels[i].green * 0.587 + pixels[i].blue * 0.114;
    }
    
    luminosity /= self.size.width * self.size.height;
    
    return luminosity;
}

- (CGFloat)luminosityFrom:(CGFloat)from to:(CGFloat)to {
    
    CGFloat luminosity = 0.0f;
    
    RGBAPixel* pixels = [self bitmap];
    
    int start = from * self.size.width * self.size.height;
    int end = to * self.size.width * self.size.height;
    
    for (int i = start; i < end; ++i) {
        luminosity += pixels[i].red * 0.299 + pixels[i].green * 0.587 + pixels[i].blue * 0.114;
    }
    
    luminosity /= self.size.width * self.size.height;
    
    return luminosity;
}
@end
