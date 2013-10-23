//
//  Database.m
//  Moobeez
//
//  Created by Radu Banea on 10/14/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "Database.h"
#import "Moobeez.h"

@implementation Database

static Database* sharedDatabase;

+ (Database*)sharedDatabase {
    if (!sharedDatabase) {
        sharedDatabase = [[Database alloc] init];
    }
    return sharedDatabase;
}

- (id)init {
    self = [super init];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:MY_DATABASE_PATH]) {
        NSString *sqLiteDb = [[NSBundle mainBundle] pathForResource:@"MoobeezDatabase"
                                                             ofType:@""];
    
        NSError* error = nil;
        
        [[NSFileManager defaultManager] copyItemAtPath:sqLiteDb toPath:MY_DATABASE_PATH error:&error];
        
        if (error) {
            NSLog(@"error: %@", error);
        }
    }
    
    
    if (sqlite3_open([MY_DATABASE_PATH UTF8String], &database) != SQLITE_OK) {
        NSLog(@"Failed to open database!");
    }
    else {
        NSLog(@"Yeeeey to open database!");
    }
    
    return self;
}

- (void)dealloc {
    sqlite3_close(database);
}

#pragma mark - General Methods

- (BOOL)insertDictionary:(NSDictionary*)dictionary intoTable:(NSString*)table {
    
    NSArray* allKeys = dictionary.allKeys;
    
    NSString* columns = [allKeys componentsJoinedByString:@","];
    
    NSMutableArray* allValues = [NSMutableArray array];
    for (NSString* key in allKeys) {
        [allValues addObject:[NSString stringWithFormat:@"%@", dictionary[key]]];
    }
    
    NSString* values = [allValues componentsJoinedByString:@","];
    
    NSString *query = [NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (%@)", table, columns, values];
    
    sqlite3_stmt *statement;
    
    NSLog(@"query: %@", query);
    
    int prepare = sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil);
    
    if (prepare != SQLITE_OK) {
        NSLog(@"prepare: %d", prepare);
        return NO;
    }
    
    int step = sqlite3_step(statement);
    
    switch (step) {
        case SQLITE_DONE:
            NSLog(@"yey");
            sqlite3_finalize(statement);
            return YES;
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
    
    return NO;
}


#pragma mark - Old To New

- (void)populateWithOldDatabase:(NSArray*)oldDatabase {
    
    NSMutableArray* untransferredDatabase = [[NSMutableArray alloc] init];
    
    for (NSDictionary* dictionary in oldDatabase) {
        
        sqlite_int64 nextId = sqlite3_last_insert_rowid(database) + 1;
        
        NSInteger tmdbId = [dictionary[@"id"] integerValue];
        
        NSString* name = [dictionary stringForKey:@"title"];
        
        NSString* comments = [dictionary stringForKey:@"comments"];
        
        NSString* posterPath = [dictionary stringForKey:@"poster"];
        
        CGFloat rating = [dictionary[@"rating"] floatValue];
        
        NSInteger isFavorite = [dictionary[@"isFavorite"] intValue];
        
        NSTimeInterval date = (dictionary[@"date"] ? [dictionary[@"date"] timeIntervalSinceReferenceDate] : -1);
        
        NSInteger type = 0;
        
        if (date >= 0) {
            type = 2;
        }
        else if ([dictionary[@"wished"] boolValue] || [dictionary[@"watchlist"] boolValue]) {
            type = 1;
            date = -1;
        }

        NSMutableDictionary* addDictionary = [[NSMutableDictionary alloc] init];
        
        addDictionary[@"ID"] = [NSString stringWithFormat:@"%ld", (long)nextId];
        addDictionary[@"tmdbId"] = [NSString stringWithFormat:@"%ld", (long)tmdbId];
        addDictionary[@"name"] = [NSString stringWithFormat:@"'%@'", name];
        addDictionary[@"comments"] = [NSString stringWithFormat:@"'%@'", comments];
        addDictionary[@"posterPath"] = [NSString stringWithFormat:@"'%@'", posterPath];
        addDictionary[@"rating"] = [NSString stringWithFormat:@"%.1f", rating];
        addDictionary[@"date"] = [NSString stringWithFormat:@"%.0f", date];
        addDictionary[@"type"] = [NSString stringWithFormat:@"%ld", (long)type];
        addDictionary[@"isFavorite"] = [NSString stringWithFormat:@"%ld", (long)isFavorite];
        
        if (![self insertDictionary:addDictionary intoTable:@"Moobeez"]) {
            [untransferredDatabase addObject:dictionary];
        }
    }
    
    if (untransferredDatabase.count == 0) {
        [[NSFileManager defaultManager] removeItemAtPath:MY_MOVIES_PATH error:nil];
    }
    else {
        [untransferredDatabase writeToFile:MY_MOVIES_PATH atomically:YES];
    }
}


#pragma mark - Moobeez

- (NSMutableArray*)moobeezWithType:(MoobeeType)type {
    
    NSString* query = @"";
    
    switch (type) {
        case MoobeeSeenType:
            query = [NSString stringWithFormat:@"SELECT * FROM Moobeez WHERE type = %d ORDER BY date DESC", type];
            break;
        case MoobeeOnWatchlistType:
            query = [NSString stringWithFormat:@"SELECT * FROM Moobeez WHERE type = %d ORDER BY ID DESC", type];
            break;
        default:
            query = [NSString stringWithFormat:@"SELECT * FROM Moobeez ORDER BY date, ID DESC"];
            break;
    }
    
    return [self moobeezWithQuery:query];
}

- (NSMutableArray*)favoritesMoobeez {
    
    return [self moobeezWithQuery:@"SELECT * FROM Moobeez WHERE isFavorite = TRUE ORDER BY date, ID DESC"];
}

- (NSMutableArray*)moobeezWithQuery:(NSString*)query {
    
    sqlite3_stmt *statement;
    
    NSMutableArray* results = [[NSMutableArray alloc] init];
    
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil)
        == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            Moobee* moobee = [[Moobee alloc] initWithDatabaseDictionary:[[NSMutableDictionary alloc] initWithSqlStatement:statement]];
            
            [results addObject:moobee];
        }
        sqlite3_finalize(statement);
    }
    
    return results;
}

- (Moobee*)moobeeWithId:(NSInteger)id {
    
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM Moobeez WHERE ID = %ld", (long)id];
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil)
        == SQLITE_OK) {
        
        Moobee* moobee = nil;
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            moobee = [[Moobee alloc] initWithDatabaseDictionary:[[NSMutableDictionary alloc] initWithSqlStatement:statement]];
            
            break;
        }
        sqlite3_finalize(statement);
        
        return moobee;
    }
    
    
    return nil;

    
}

@end
