//
//  BasicDatabase.m
//  Moobeez
//
//  Created by Radu Banea on 06/06/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "BasicDatabase.h"
#import "NSMutableDictionary+SQL.h"

@implementation BasicDatabase

static BasicDatabase* sharedDatabase;

+ (BasicDatabase*)sharedDatabase {
    if (!sharedDatabase) {
        sharedDatabase = [[BasicDatabase alloc] init];
    }
    return sharedDatabase;
}

- (NSInteger)generateNewId {
    NSInteger lastId = [[[NSUserDefaults standardUserDefaults] objectForKey:@"lastId"] integerValue];
    if (lastId < 0) {
        lastId = 0;
    }
    else {
        lastId++;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:lastId] forKey:@"lastId"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return lastId;
}

- (id)initWithPath:(NSString*)path placeholderPath:(NSString*)placeholderPath {
    self = [super init];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path] && placeholderPath) {
    
        NSError* error = nil;
        
        [[NSFileManager defaultManager] copyItemAtPath:placeholderPath toPath:path error:&error];
        
        if (error) {
            NSLog(@"error: %@", error);
        }
    }
    
    
    if (sqlite3_open([path UTF8String], &database) != SQLITE_OK) {
        NSLog(@"Failed to open database!");
    }
    else {
        NSLog(@"Yeeeey to open database!");
    }
    
    return self;
}

- (id)init {
    self = [self initWithPath:DATABASE_PATH placeholderPath:[[NSBundle mainBundle] pathForResource:@"Database" ofType:@""]];
    return self;
}

- (void)dealloc {
    sqlite3_close(database);
}

#pragma mark - General Methods

- (NSMutableArray*)executeQuery:(NSString*)query {
    
    NSLog(@"Execute query: %@", query);
    
    sqlite3_stmt *statement;
    
    int prepare = sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil);
    
    if (prepare != SQLITE_OK) {
        NSLog(@"prepare: %d", prepare);
        if (prepare == SQLITE_ERROR) {
            NSLog(@"%s SQLITE_ERROR '%s' (%1d)", __FUNCTION__, sqlite3_errmsg(database), sqlite3_errcode(database));
        }
        return nil;
    }
    
    int step = sqlite3_step(statement);
    
    NSMutableArray* results = [[NSMutableArray alloc] init];
    
    while (step == SQLITE_ROW) {
        [results addObject:[[NSMutableDictionary alloc] initWithSqlStatement:statement]];
        step = sqlite3_step(statement);
    }
    
    BOOL isOk = (step == SQLITE_DONE);
    
    switch (step) {
        case SQLITE_DONE:
            NSLog(@"yey");
            break;
        case SQLITE_ERROR:
            NSLog(@"error");
            break;
        case SQLITE_MISUSE:
            NSLog(@"missue");
            break;
        default:
            NSLog(@"NOOOOO!!!");
            break;
    }
    
    sqlite3_finalize(statement);
    
    return (isOk ? results : nil);
}

- (NSInteger)insertDictionary:(NSDictionary*)dictionary intoTable:(NSString*)table {
    
    sqlite_int64 nextId = -1;
    
    NSMutableDictionary* dictionaryWithId = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    
    if (!dictionaryWithId[@"id"]) {
        nextId = [self generateNewId];
        dictionaryWithId[@"id"] = [NSString stringWithFormat:@"%lld", nextId];
    }
    else {
        nextId = [dictionaryWithId[@"id"] longLongValue];
    }
    
    NSArray* allKeys = dictionaryWithId.allKeys;
    
    NSString* columns = [allKeys componentsJoinedByString:@","];
    
    NSMutableArray* allValues = [[NSMutableArray alloc] init];
    
    for (NSString* key in allKeys) {
        NSString* value = dictionaryWithId[key];
        if ([value isKindOfClass:[NSString class]]) {
            value = [value stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        }
        [allValues addObject:[NSString stringWithFormat:@"'%@'", value]];
    }
    
    NSString* values = [allValues componentsJoinedByString:@","];
    
    NSString *query = [NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (%@)", table, columns, values];
    
    if ([self executeQuery:query]) {
        return nextId;
    }
    else {
        return -1;
    }
}

- (NSMutableArray*)insertObjects:(NSArray*)objects atKeys:(NSArray*)keys intoTable:(NSString*)table {
    
    sqlite_int64 nextId = [self generateNewId];
    
    NSMutableArray* valuesArray = [[NSMutableArray alloc] init];
    
    NSMutableArray* allKeys = [[NSMutableArray alloc] initWithArray:keys];
    if (![allKeys containsObject:@"id"]) {
        [allKeys addObject:@"id"];
    }
    
    NSString* columns = [allKeys componentsJoinedByString:@","];

    NSMutableArray* ids = [[NSMutableArray alloc] init];
    
    for (NSDictionary* dictionary in objects) {
        
        NSMutableDictionary* dictionaryWithId = [NSMutableDictionary dictionaryWithDictionary:dictionary];
        
        if (!dictionaryWithId[@"id"]) {
            dictionaryWithId[@"id"] = [NSString stringWithFormat:@"%lld", nextId];
        }
        else {
            nextId = [dictionaryWithId[@"id"] longLongValue];
        }
        
        [ids addObject:@(nextId)];
        
        NSMutableArray* allValues = [[NSMutableArray alloc] init];
        
        for (NSString* key in allKeys) {
            NSString* value = dictionaryWithId[key];
            if ([value isKindOfClass:[NSString class]]) {
                value = [value stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            }
            [allValues addObject:[NSString stringWithFormat:@"'%@'", value]];
        }
        
        NSString* values = [NSString stringWithFormat:@"(%@)", [allValues componentsJoinedByString:@","]];
        
        [valuesArray addObject:values];
    }
    
    NSString *query = [NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES %@", table, columns, [valuesArray componentsJoinedByString:@", "]];
    
    if ([self executeQuery:query]) {
        return ids;
    }
    else {
        return nil;
    }
}

- (BOOL)updateDictionary:(NSDictionary*)dictionary intoTable:(NSString*)table where:(NSDictionary*)whereDictionary {
    
    NSMutableArray* setValues = [NSMutableArray array];
    for (NSString* key in dictionary.allKeys) {
        id value = dictionary[key];
        if ([value isKindOfClass:[NSString class]]) {
            value = [value stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        }

        [setValues addObject:[NSString stringWithFormat:@"%@='%@'", key, value]];
    }
    
    NSString* set = [setValues componentsJoinedByString:@","];
    
    NSMutableArray* whereValues = [NSMutableArray array];
    for (NSString* key in whereDictionary.allKeys) {
        
        id value = whereDictionary[key];
        
        if ([value isKindOfClass:[NSString class]]) {
            value = [value stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        }

        [whereValues addObject:[NSString stringWithFormat:@"%@='%@'", key, value]];
    }
    
    NSString* where = [whereValues componentsJoinedByString:@" AND "];
    
    NSString *query = [NSString stringWithFormat:@"UPDATE %@ SET %@", table, set];
    
    if (where.length) {
        
        query = [query stringByAppendingFormat:@" WHERE %@", where];
        
    }
    
    return [self executeQuery:query];
}

- (BOOL)clearTable:(NSString*)tableName {
    
    NSString *query = [NSString stringWithFormat:@"DELETE FROM %@", tableName];
    
    return [self executeQuery:query];
}

- (BOOL)deleteFromTable:(NSString*)tableName where:(NSDictionary*)whereDictionary  {
    
    NSMutableArray* whereValues = [NSMutableArray array];
    for (NSString* key in whereDictionary.allKeys) {
        [whereValues addObject:[NSString stringWithFormat:@"%@='%@'", key, whereDictionary[key]]];
    }
    
    NSString* where = [whereValues componentsJoinedByString:@" AND "];
    
    NSString *query = [NSString stringWithFormat:@"DELETE FROM %@", tableName];
    
    if (where.length) {
        
        query = [query stringByAppendingFormat:@" WHERE %@", where];
        
    }

    return [self executeQuery:query];
}

@end
