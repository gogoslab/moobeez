//
//  NSMutableDictionary+Extensions.h
//  Gogz
//
//  Created by Radu Banea on 10/11/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (Extensions)

- (void)setString:(NSString*)value forKey:(NSString *)aKey;
- (void)setInteger:(NSInteger)value forKey:(NSString *)aKey;
- (void)setFloat:(CGFloat)value forKey:(NSString *)aKey;
- (void)setDouble:(double)value forKey:(NSString *)aKey;
- (void)setBool:(BOOL)value forKey:(NSString *)aKey;

@end
