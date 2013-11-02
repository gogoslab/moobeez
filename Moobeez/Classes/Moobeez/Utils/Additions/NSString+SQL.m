//
//  NSString+SQL.m
//  Moobeez
//
//  Created by Radu Banea on 30/10/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "NSString+SQL.h"

@implementation NSString (SQL)

- (NSString*)stringByResolvingSQLIssues {
    if (self.length) {
        return [self stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    }
    return @"";
}

@end
