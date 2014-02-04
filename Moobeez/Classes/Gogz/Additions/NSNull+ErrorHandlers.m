//
//  NSNull+ErrorHandlers.m
//  Moobeez
//
//  Created by Radu Banea on 04/02/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "NSNull+ErrorHandlers.h"

@implementation NSNull (ErrorHandlers)

- (NSInteger)integerValue {
    return 0;
}

- (CGFloat)floatValue {
    return 0.0;
}

- (NSInteger)lenght {
    return 0;
}

- (BOOL)isEqualToString:(NSString*)string {
    return NO;
}

@end
