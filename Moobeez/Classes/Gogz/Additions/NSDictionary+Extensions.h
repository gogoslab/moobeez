//
//  NSDictionary+Extensions.h
//  Gogz
//
//  Created by Radu Banea on 10/11/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Extensions)

- (NSString*)stringForKey:(id)key;
- (NSInteger)integerForKey:(id)key;
- (CGFloat)floatForKey:(id)key;
- (double)doubleForKey:(id)key;
- (BOOL)boolForKey:(id)key;

@end
