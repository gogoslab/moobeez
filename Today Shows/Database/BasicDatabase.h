//
//  BasicDatabase.h
//  Moobeez
//
//  Created by Radu Banea on 06/06/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "Constants.h"

#define DATABASE_PATH CURRENT_DATABASE_PATH

@interface BasicDatabase : NSObject {
    sqlite3 *database;
}

+ (BasicDatabase*)sharedDatabase;

- (id)initWithPath:(NSString*)path placeholderPath:(NSString*)placeholderPath;

- (NSMutableArray*)executeQuery:(NSString*)query;

- (NSInteger)insertDictionary:(NSDictionary*)dictionary intoTable:(NSString*)table;
- (NSMutableArray*)insertObjects:(NSArray*)objects atKeys:(NSArray*)keys intoTable:(NSString*)table;

- (BOOL)updateDictionary:(NSDictionary*)dictionary intoTable:(NSString*)table where:(NSDictionary*)whereDictionary;
- (BOOL)deleteFromTable:(NSString*)tableName where:(NSDictionary*)whereDictionary;
- (BOOL)clearTable:(NSString*)tableName;

@end
