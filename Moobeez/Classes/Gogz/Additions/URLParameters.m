//
//  URLParameters.m
//  Moobeez
//
//  Created by Radu Banea on 10/14/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "URLParameters.h"

@implementation NSURL (Parameters)

- (NSDictionary*)parametersDictionary {
    return [self.absoluteString parametersDictionary];
}

@end

@implementation NSString (Parameters)

- (NSDictionary*)parametersDictionary {
    NSString* parameters = [self substringFromIndex:[self rangeOfString:@"?"].location + 1];
    NSArray* components = [parameters componentsSeparatedByString:@"&"];
    NSMutableDictionary* parametersDictionary = [NSMutableDictionary dictionary];
    for (NSString* component in components) {
        NSRange range = [component rangeOfString:@"="];
        NSString* parameter = [component substringToIndex:range.location];
        NSString* value = [component substringFromIndex:range.location + 1];
        [parametersDictionary setObject:value forKey:parameter];
    }
    
    return parametersDictionary;
}

@end

@implementation NSDictionary (Parameters)

- (NSString*)parametersString {
    
    NSString* parametersString = @"";
    
    for (NSString* key in self.allKeys) {
        if (parametersString.length) {
            parametersString = [parametersString stringByAppendingString:@"&"];
        }
        else {
            parametersString = [parametersString stringByAppendingString:@"?"];
        }
        
        parametersString = [parametersString stringByAppendingFormat:@"%@=%@", key, self[key]];
    }
    
    return parametersString;
}

- (NSURL*)parametersURL {
    
    return [NSURL URLWithString:self.parametersString];
}

@end
