//
//  NSObject+Mutable.h
//  Gogz
//
//  Created by Radu Banea on 10/11/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "NSObject+Mutable.h"

@implementation NSObject (Mutable)

- (NSObject*)mutableObject {
    
    if ([self isKindOfClass:[NSArray class]]) {
        NSMutableArray* mutableArray = [NSMutableArray array];
        
        for (NSObject* object in (NSMutableArray*) self) {
            [mutableArray addObject:[object mutableObject]];
        }
        
        return mutableArray;
    }
    
    if ([self isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary* mutableDictionary = [NSMutableDictionary dictionary];
        
        for (NSString* key in [(NSDictionary*) self allKeys]) {
            [mutableDictionary setObject:[[(NSDictionary*) self objectForKey:key] mutableObject] forKey:key];
        }
        
        return mutableDictionary;
    }
    
    if ([self isKindOfClass:[NSData class]]) {
        
        return [NSMutableData dataWithData:(NSData*) self];
    }
    
    return self;
    
}

@end
