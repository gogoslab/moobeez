//
//  NSMutableDictionary+SQL.h
//  Moobeez
//
//  Created by Radu Banea on 10/14/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface NSMutableDictionary (SQL)

- (id)initWithSqlStatement:(sqlite3_stmt*)statement;

@end
