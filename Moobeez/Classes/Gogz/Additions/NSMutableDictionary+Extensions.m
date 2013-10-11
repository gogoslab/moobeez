//
//  NSMutableDictionary+Extensions.m
//  Gogz
//
//  Created by Radu Banea on 10/11/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "NSMutableDictionary+Extensions.h"

@implementation NSMutableDictionary (Extensions)

- (void)setString:(NSString*)value forKey:(NSString *)aKey {
    if (!value || [value isKindOfClass:[NSNull class]]) {
        [self setObject:@"" forKey:aKey];
        return;
    }

    [self setObject:[NSString stringWithFormat:@"%@",value] forKey:aKey];
}

- (void)setInteger:(NSInteger)value forKey:(NSString *)aKey {
    [self setObject:[NSNumber numberWithInteger:value] forKey:aKey];
}

- (void)setFloat:(CGFloat)value forKey:(NSString *)aKey {
    [self setObject:[NSNumber numberWithFloat:value] forKey:aKey];
}

- (void)setDouble:(double)value forKey:(NSString *)aKey {
    [self setObject:[NSNumber numberWithDouble:value] forKey:aKey];
}

- (void)setBool:(BOOL)value forKey:(NSString *)aKey {
    [self setObject:[NSNumber numberWithBool:value] forKey:aKey];
}

@end
