//
//  NSDictionary+Extensions.m
//  Gogz
//
//  Created by Radu Banea on 10/11/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "NSDictionary+Extensions.h"

@implementation NSDictionary (Extensions)

- (NSString*)stringForKey:(id)key {
    if (![self objectForKey:key] || [[self objectForKey:key] isKindOfClass:[NSNull class]]) {
        return @"";
    }
    
    return [NSString stringWithFormat:@"%@",[self objectForKey:key]];
}

- (NSInteger)integerForKey:(id)key {
    if ([[self objectForKey:key] isKindOfClass:[NSNumber class]] || [[self objectForKey:key] isKindOfClass:[NSString class]]) {
        return [[self objectForKey:key] intValue];
    }
    
    return NSNotFound;
}

- (CGFloat)floatForKey:(id)key {
    if ([[self objectForKey:key] isKindOfClass:[NSNumber class]] || [[self objectForKey:key] isKindOfClass:[NSString class]]) {
        return [[self objectForKey:key] floatValue];
    }
    
    return NSNotFound;
}

- (double)doubleForKey:(id)key {
    if ([[self objectForKey:key] isKindOfClass:[NSNumber class]] || [[self objectForKey:key] isKindOfClass:[NSString class]]) {
        return [[self objectForKey:key] doubleValue];
    }
    
    return NSNotFound;
}

- (BOOL)boolForKey:(id)key {
    if ([[self objectForKey:key] isKindOfClass:[NSNumber class]] || [[self objectForKey:key] isKindOfClass:[NSString class]]) {
        return [[self objectForKey:key] boolValue];
    }
    
    return NO;
}

@end
