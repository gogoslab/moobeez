//
//  NSMutableDictionary+SQL.h
//  Moobeez
//
//  Created by Radu Banea on 06/06/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface NSMutableDictionary (SQL)

- (id)initWithSqlStatement:(sqlite3_stmt*)statement;

@end
