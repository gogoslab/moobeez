//
//  NSMutableDictionary+SQL.m
//  Moobeez
//
//  Created by Radu Banea on 06/06/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "NSMutableDictionary+SQL.h"

@implementation NSMutableDictionary (SQL)

- (id)initWithSqlStatement:(sqlite3_stmt*)statement {
    
    self = [self init];
    
    if (self) {
        
        int colsCount = sqlite3_column_count(statement);
        for (int i = 0; i < colsCount; ++i) {
            
            NSString* key = [self keyAtIndex:i inStatement:statement];
            
            if (key.length == 0) {
                continue;
            }
            
            NSString* value = [self valueAtIndex:i inStatement:statement];
            
            self[key] = value;
        }
    }
    
    return self;
}

- (NSString*)valueAtIndex:(int)index inStatement:(sqlite3_stmt*)statement {
    @try {
        return [NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, index)];
    }
    @catch (NSException *exception) {
        return @"";
    }
    @finally {
    }
}

- (NSString*)keyAtIndex:(int)index inStatement:(sqlite3_stmt*)statement {
    @try {
        return [NSString stringWithUTF8String:(char *) sqlite3_column_name(statement, index)];
    }
    @catch (NSException *exception) {
        return @"";
    }
    @finally {
    }
}

@end
