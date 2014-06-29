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

- (NSInteger)generateNewId {
    NSInteger lastId = [[[NSUserDefaults standardUserDefaults] objectForKey:@"lastId"] integerValue];
    if (lastId < 300) {
        lastId = 300;
    }
    else {
        lastId++;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:lastId] forKey:@"lastId"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return lastId;
}

- (BOOL)recalculateLastIdFromTable:(NSString*)table {
    
    NSString* query = [NSString stringWithFormat:@"SELECT ID FROM %@ ORDER BY ID DESC LIMIT 1", table];
    
    NSInteger lastId = [[[NSUserDefaults standardUserDefaults] objectForKey:@"lastId"] integerValue];
    
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil)
        == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
             NSInteger ID = [[[NSMutableDictionary alloc] initWithSqlStatement:statement][@"ID"] integerValue];
            
            if (ID < lastId) {
                sqlite3_finalize(statement);
                return NO;
            }
            
            lastId = ID;
        }
        
    }

    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:lastId] forKey:@"lastId"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return YES;
}

- (NSInteger)lastIdFromTable:(NSString*)table {
    
    NSString* query = [NSString stringWithFormat:@"SELECT ID FROM %@ ORDER BY ID DESC LIMIT 1", table];
    
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil)
        == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            NSInteger ID = [[[NSMutableDictionary alloc] initWithSqlStatement:statement][@"ID"] integerValue];

            sqlite3_finalize(statement);
            return ID;
        }
        
    }
    
    return 0;
}


- (id)init {
    self = [super init];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:CURRENT_DATABASE_PATH]) {
        
        NSString *sqLiteDb = [[NSBundle mainBundle] pathForResource:@"MoobeezDatabase"
                                                             ofType:@""];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:OLD_DATABASE_PATH]) {
            sqLiteDb = OLD_DATABASE_PATH;
        }
        
        NSError* error = nil;
        
        [[NSFileManager defaultManager] moveItemAtPath:sqLiteDb toPath:CURRENT_DATABASE_PATH error:&error];
        
        if (error) {
            NSLog(@"error: %@", error);
        }
    }
    
    
    if (sqlite3_open([CURRENT_DATABASE_PATH UTF8String], &database) != SQLITE_OK) {
        NSLog(@"Failed to open database!");
    }
    else {
        NSLog(@"Yeeeey to open database!");
        
        NSString* oldDatabasePath = nil;
        
        for (NSString* subpath in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[CURRENT_DATABASE_PATH stringByDeletingLastPathComponent] error:nil]) {
            if ([[subpath lastPathComponent] rangeOfString:DATABASE_NAME].location != NSNotFound) {
                if (![VERSION_OF_DATABASE(subpath) isEqualToString:DATABASE_VERSION]) {
                    oldDatabasePath = subpath;
                    break;
                }
            }
        }
        
        if (oldDatabasePath) {
            oldDatabasePath = [[CURRENT_DATABASE_PATH stringByDeletingLastPathComponent] stringByAppendingPathComponent:oldDatabasePath];
        }
        else {
            for (NSString* subpath in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[OLD_DATABASE_PATH stringByDeletingLastPathComponent] error:nil]) {
                if ([[subpath lastPathComponent] rangeOfString:DATABASE_NAME].location != NSNotFound) {
                    if (![VERSION_OF_DATABASE(subpath) isEqualToString:DATABASE_VERSION]) {
                        oldDatabasePath = subpath;
                        break;
                    }
                }
            }
            
            if (oldDatabasePath) {
                oldDatabasePath = [[OLD_DATABASE_PATH stringByDeletingLastPathComponent] stringByAppendingPathComponent:oldDatabasePath];
            }
        }

        if ([[NSFileManager defaultManager] fileExistsAtPath:oldDatabasePath]) {
            
            NSString* attach = [NSString stringWithFormat:@"ATTACH DATABASE '%@' AS OldDatabase", oldDatabasePath];
            
            char* errorMessage;
            
            BOOL everthingOk = NO;
            
            if (sqlite3_exec(database, [attach UTF8String], NULL, NULL, &errorMessage) == SQLITE_OK)
            {
                sqlite3_stmt *statement;
                
                NSString* query = @"SELECT name FROM sqlite_master WHERE type='table'";
                
                if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil)
                    == SQLITE_OK) {
                    
                    everthingOk = YES;
                    
                    while (sqlite3_step(statement) == SQLITE_ROW) {
                        
                        NSString* tableName = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 0)];
                        
                        [self clearTable:tableName];
                        
                        NSString* copyTables = [NSString stringWithFormat:@"INSERT INTO %@ SELECT * FROM OldDatabase.%@", tableName, tableName];
                        
                        sqlite3_stmt *copyStatement;
                        
                        if (sqlite3_prepare_v2(database, [copyTables UTF8String], -1, &copyStatement, nil)
                            == SQLITE_OK) {
                            int step = sqlite3_step(copyStatement);
                            
                            switch (step) {
                                case SQLITE_DONE:
                                    NSLog(@"yey");
                                    break;
//                                case SQLITE_ERROR:
//                                    NSLog(@"error");
//                                    break;
//                                case SQLITE_MISUSE:
//                                    NSLog(@"missue");
//                                    break;
                                default:
                                    NSLog(@"NOOOOO!!!");
                                    everthingOk = NO;
                                    break;
                            }
                        }
                        sqlite3_finalize(copyStatement);
                    }
                    sqlite3_finalize(statement);
                }
                
                if (everthingOk) {
                    [[NSFileManager defaultManager] removeItemAtPath:oldDatabasePath error:nil];
                }
            }
        }
    }
    
    return self;
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

- (void)dealloc {
    sqlite3_close(database);
}

#pragma mark - General Methods

- (NSInteger)insertDictionary:(NSDictionary*)dictionary intoTable:(NSString*)table {
    
    sqlite_int64 nextId = [self lastIdFromTable:table] + 1;

    NSMutableDictionary* dictionaryWithId = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    
    dictionaryWithId[@"ID"] = [NSString stringWithFormat:@"%lld", nextId];
    
    NSArray* allKeys = dictionaryWithId.allKeys;
    
    NSString* columns = [allKeys componentsJoinedByString:@","];
    
    NSMutableArray* allValues = [[NSMutableArray alloc] init];
    
    for (NSString* key in allKeys) {
        [allValues addObject:[NSString stringWithFormat:@"'%@'", dictionaryWithId[key]]];
    }
    
    NSString* values = [allValues componentsJoinedByString:@","];
    
    NSString *query = [NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (%@)", table, columns, values];
    
    sqlite3_stmt *statement;
    
    NSLog(@"query: %@", query);
    
    int prepare = sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil);
    
    if (prepare != SQLITE_OK) {
        NSLog(@"prepare: %d", prepare);
        if (prepare == SQLITE_ERROR) {
            NSLog(@"%s SQLITE_ERROR '%s' (%1d)", __FUNCTION__, sqlite3_errmsg(database), sqlite3_errcode(database));
        }
        return -1;
    }
    
    int step = sqlite3_step(statement);
    
    switch (step) {
        case SQLITE_DONE:
            NSLog(@"yey");
            sqlite3_finalize(statement);
            return nextId;
            break;
        case SQLITE_ERROR:
            NSLog(@"error");
            break;
        case SQLITE_MISUSE:
            NSLog(@"missue");
            break;
        case SQLITE_CONSTRAINT:
            if ([self recalculateLastIdFromTable:table]) {
                sqlite3_finalize(statement);
                return [self insertDictionary:dictionary intoTable:table];
            }
            break;
        default:
            NSLog(@"NOOOOO!!!");
            break;
    }
    
    sqlite3_finalize(statement);
    
    return -1;
}

- (NSMutableArray*)insertObjects:(NSArray*)objects atKeys:(NSArray*)keys intoTable:(NSString*)table {
    
    NSMutableArray* valuesArray = [[NSMutableArray alloc] init];
    
    NSMutableArray* allKeys = [[NSMutableArray alloc] initWithArray:keys];
    if (![allKeys containsObject:@"ID"]) {
        [allKeys addObject:@"ID"];
    }
    
    NSString* columns = [allKeys componentsJoinedByString:@","];
    
    NSMutableArray* ids = [[NSMutableArray alloc] init];
    
    sqlite_int64 nextId = [self lastIdFromTable:table] + 1;
    
    for (NSDictionary* dictionary in objects) {

        NSMutableDictionary* dictionaryWithId = [NSMutableDictionary dictionaryWithDictionary:dictionary];
        
        if (!dictionaryWithId[@"ID"]) {
            dictionaryWithId[@"ID"] = [NSString stringWithFormat:@"%lld", nextId];
        }
        else {
            nextId = [dictionaryWithId[@"ID"] longLongValue];
        }
        
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
        
        [ids addObject:@(nextId)];
        
        nextId++;
    }
    
    NSString *query = [NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES %@", table, columns, [valuesArray componentsJoinedByString:@", "]];
    
    sqlite3_stmt *statement;
    
    NSLog(@"query: %@", query);
    
    int prepare = sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil);
    
    if (prepare != SQLITE_OK) {
        NSLog(@"prepare: %d", prepare);
        if (prepare == SQLITE_ERROR) {
            NSLog(@"%s SQLITE_ERROR '%s' (%1d)", __FUNCTION__, sqlite3_errmsg(database), sqlite3_errcode(database));
        }
        return nil;
    }
    
    int step = sqlite3_step(statement);
    
    switch (step) {
        case SQLITE_DONE:
            NSLog(@"yey");
            sqlite3_finalize(statement);
            return ids;
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
    
    return nil;
}

- (BOOL)updateDictionary:(NSDictionary*)dictionary intoTable:(NSString*)table where:(NSDictionary*)whereDictionary {
    
    NSMutableArray* setValues = [NSMutableArray array];
    for (NSString* key in dictionary.allKeys) {
        [setValues addObject:[NSString stringWithFormat:@"%@='%@'", key, dictionary[key]]];
    }
    
    NSString* set = [setValues componentsJoinedByString:@","];
    
    NSMutableArray* whereValues = [NSMutableArray array];
    for (NSString* key in whereDictionary.allKeys) {
        [whereValues addObject:[NSString stringWithFormat:@"%@='%@'", key, whereDictionary[key]]];
    }
    
    NSString* where = [whereValues componentsJoinedByString:@" AND "];
    
    NSString *query = [NSString stringWithFormat:@"UPDATE %@ SET %@", table, set];
    
    if (where.length) {
        
        query = [query stringByAppendingFormat:@" WHERE %@", where];
        
    }
    
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

- (BOOL)updateColumnValues:(NSArray*)values forColumn:(NSString*)column intoTable:(NSString*)table forIds:(NSArray*)ids {

    NSString* set = [NSString stringWithFormat:@"%@ = CASE ID", column];
    for (int i = 0; i < MIN(values.count, ids.count) ; ++i) {
        set = [set stringByAppendingFormat:@"\n WHEN %@ THEN '%@'", ids[i], values[i]];
    }
    set = [set stringByAppendingString:@"\nEND"];
    
    NSString* where = [NSString stringWithFormat:@"ID in (%@)", [ids componentsJoinedByString:@","]];
    
    NSString *query = [NSString stringWithFormat:@"UPDATE %@ SET %@", table, set];
    
    if (where.length) {
        
        query = [query stringByAppendingFormat:@" WHERE %@", where];
        
    }
    
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

- (void)populateWithOldDatabase {
    
    NSArray* oldDatabase = [[NSArray alloc] initWithContentsOfFile:MY_MOVIES_PATH];

    if (!oldDatabase.count) {
        return;
    }
    
    NSMutableArray* untransferredDatabase = [[NSMutableArray alloc] init];
    
    for (NSDictionary* dictionary in oldDatabase) {
        
        NSInteger tmdbId = [dictionary[@"id"] integerValue];
        
        NSString* name = [[dictionary stringForKey:@"title"] stringByResolvingSQLIssues];
        
        NSString* comments = [[dictionary stringForKey:@"comments"] stringByResolvingSQLIssues];
        
        NSString* posterPath = [[dictionary stringForKey:@"poster"] stringByResolvingSQLIssues];
        
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
        
        addDictionary[@"tmdbId"] = [NSString stringWithFormat:@"%ld", (long)tmdbId];
        addDictionary[@"name"] = [NSString stringWithFormat:@"%@", name];
        addDictionary[@"comments"] = [NSString stringWithFormat:@"%@", comments];
        addDictionary[@"posterPath"] = [NSString stringWithFormat:@"%@", posterPath];
        addDictionary[@"rating"] = [NSString stringWithFormat:@"%.1f", rating];
        addDictionary[@"date"] = [NSString stringWithFormat:@"%.0f", date];
        addDictionary[@"type"] = [NSString stringWithFormat:@"%ld", (long)type];
        addDictionary[@"isFavorite"] = [NSString stringWithFormat:@"%ld", (long)isFavorite];
        
        if ([self insertDictionary:addDictionary intoTable:@"Moobeez"] == -1) {
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

- (void)replaceOldDatabase {
    
    [self clearTable:@"Moobeez"];
    
    [self populateWithOldDatabase];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DatabaseDidReloadNotification object:nil userInfo:nil];

}

- (void)clearTable:(NSString*)tableName {
    
    NSString *query = [NSString stringWithFormat:@"DELETE FROM %@", tableName];
    
    sqlite3_stmt *statement;
    
    NSLog(@"query: %@", query);
    
    int prepare = sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil);
    
    if (prepare != SQLITE_OK) {
        NSLog(@"prepare: %d", prepare);
        return;
    }
    
    int step = sqlite3_step(statement);
    
    switch (step) {
        case SQLITE_DONE:
            NSLog(@"clear table: %@", tableName);
            break;
        case SQLITE_ERROR:
            NSLog(@"error clear table: %@", tableName);
            break;
        case SQLITE_MISUSE:
            NSLog(@"misuse clear table: %@", tableName);
            break;
        default:
            NSLog(@"unkown clear table: %@", tableName);
            break;
    }
    
    sqlite3_finalize(statement);
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
            query = [NSString stringWithFormat:@"SELECT * FROM Moobeez ORDER BY date DESC, ID DESC"];
            break;
    }
    
    return [self moobeezWithQuery:query];
}

- (NSMutableArray*)favoritesMoobeez {
    
    return [self moobeezWithQuery:@"SELECT * FROM Moobeez WHERE isFavorite = '1' ORDER BY date DESC, ID DESC"];
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

- (Moobee*)moobeeWithTmdbId:(NSInteger)tmdbId {
    
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM Moobeez WHERE tmdbId = %ld", (long)tmdbId];
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

- (BOOL)saveMoobee:(Moobee*)moobee {
    
    NSMutableDictionary* moobeeDictionary = moobee.databaseDictionary;
    
    if (moobee.id != -1) {
        
        if ([self updateDictionary:moobee.databaseDictionary intoTable:@"Moobeez" where:@{@"ID" : [NSString stringWithFormat:@"%ld", (long)moobee.id]}]) {
            return YES;
        }
        
    }
    
    NSInteger moobeeId = [self insertDictionary:moobeeDictionary intoTable:@"Moobeez"];
    
    moobee.id = moobeeId;
    
    if (moobeeId != -1) {
        [[NSNotificationCenter defaultCenter] postNotificationName:MoobeezDidReloadNotification object:nil userInfo:nil];
    }
    
    return (moobeeId != -1);
    
}

- (BOOL)deleteMoobee:(Moobee*)moobee {
    
    sqlite3_stmt *statement;
    
    NSString *query;
    
    int prepare;
    
    query = [NSString stringWithFormat:@"DELETE FROM Moobeez WHERE ID = '%@'",StringInteger((long)moobee.id)];
    
    prepare = sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil);
    
    if (prepare != SQLITE_OK) {
        NSLog(@"prepare: %d", prepare);
        if (prepare == SQLITE_ERROR) {
            NSLog(@"%s SQLITE_ERROR '%s' (%1d)", __FUNCTION__, sqlite3_errmsg(database), sqlite3_errcode(database));
        }
        return NO;
    }
    else {
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
        }
        sqlite3_finalize(statement);
    }
    
    moobee.id = -1;
    
    return YES;
}

#pragma mark - Teebeez

- (NSMutableArray*)teebeezWithType:(TeebeeType)type {
    
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    
    NSString* query = @"";
    
    switch (type) {
        case TeebeeToSeeType:
            query = [NSString stringWithFormat:@"SELECT Teebeez.*, SUM(CASE WHEN Episodes.watched = '0' THEN 1 ELSE 0 END) AS notWatchedEpisodesCount, SUM(CASE WHEN Episodes.watched = '1' THEN 1 ELSE 0 END) AS watchedEpisodesCount FROM Teebeez JOIN Episodes ON (Teebeez.ID = Episodes.teebeeId AND Episodes.airDate < %f) GROUP BY Teebeez.ID HAVING notWatchedEpisodesCount > 0", now];
            break;
        case TeebeeSoonType:
            query = [NSString stringWithFormat:@"SELECT Teebeez.*, e1.* FROM Teebeez JOIN (SELECT teebeeId, seasonNumber, episodeNumber, min(airDate) airDate FROM Episodes WHERE (airDate <> '(null)' AND airDate >= '%f') GROUP BY teebeeId) e1 ON (Teebeez.ID = e1.teebeeId)", now];
            break;
        default:
            query = [NSString stringWithFormat:@"SELECT Teebeez.*, SUM(CASE WHEN Episodes.watched = '0' AND Episodes.airDate < %f THEN 1 ELSE 0 END) AS notWatchedEpisodesCount, SUM(CASE WHEN Episodes.watched = '1' THEN 1 ELSE 0 END) AS watchedEpisodesCount FROM Teebeez JOIN Episodes ON (Teebeez.ID = Episodes.teebeeId) GROUP BY Teebeez.ID ORDER BY Teebeez.ID DESC",now];
            break;
    }
    
    return [self teebeezWithQuery:query];
}

- (NSMutableArray*)teebeezToUpdate {
    
    NSTimeInterval now = [[[NSDate date] resetToMidnight] timeIntervalSince1970];
    
    NSString* query = [NSString stringWithFormat:@"SELECT * FROM Teebeez WHERE (ended = NULL OR ended = '0') AND (lastUpdate = NULL OR lastUpdate < '%f')", now - [Settings sharedSettings].updateShowsInterval * 24 * 3600];
    
    return [self teebeezWithQuery:query];

}

- (NSMutableArray*)teebeezWithQuery:(NSString*)query {
    
    sqlite3_stmt *statement;
    
    NSMutableArray* results = [[NSMutableArray alloc] init];
    
    int prepare = sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil);
    
    if (prepare != SQLITE_OK) {
        NSLog(@"prepare: %d", prepare);
        if (prepare == SQLITE_ERROR) {
            NSLog(@"%s SQLITE_ERROR '%s' (%1d)", __FUNCTION__, sqlite3_errmsg(database), sqlite3_errcode(database));
        }
    }
    else {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            Teebee* teebee = [[Teebee alloc] initWithDatabaseDictionary:[[NSMutableDictionary alloc] initWithSqlStatement:statement]];
            
            [results addObject:teebee];
        }
        sqlite3_finalize(statement);
    }
    
    return results;
}

- (Teebee*)teebeeWithId:(NSInteger)id {
    
    NSString *query = [NSString stringWithFormat:@"SELECT Teebeez.* ,SUM(CASE WHEN Episodes.watched = '0' AND Episodes.airDate < %f THEN 1 ELSE 0 END) AS notWatchedEpisodesCount, SUM(CASE WHEN Episodes.watched = '1' THEN 1 ELSE 0 END) AS watchedEpisodesCount FROM Teebeez JOIN Episodes ON Teebeez.ID = Episodes.teebeeId WHERE Teebeez.ID = %ld", [[NSDate date] timeIntervalSince1970], (long)id];
    sqlite3_stmt *statement;
    
    int prepare = sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil);
    
    if (prepare != SQLITE_OK) {
        NSLog(@"prepare: %d", prepare);
        if (prepare == SQLITE_ERROR) {
            NSLog(@"%s SQLITE_ERROR '%s' (%1d)", __FUNCTION__, sqlite3_errmsg(database), sqlite3_errcode(database));
        }
    }
    else {
        
        Teebee* teebee = nil;
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            teebee = [[Teebee alloc] initWithDatabaseDictionary:[[NSMutableDictionary alloc] initWithSqlStatement:statement]];
            
            break;
        }
        sqlite3_finalize(statement);
        
        return teebee;
    }
    
    
    return nil;
}

- (Teebee*)teebeeWithTmdbId:(NSInteger)tmdbId {
    
    NSString *query = [NSString stringWithFormat:@"SELECT Teebeez.* , SUM(CASE WHEN Episodes.watched = '0' AND Episodes.airDate < %f THEN 1 ELSE 0 END) AS notWatchedEpisodesCount, SUM(CASE WHEN Episodes.watched = '1' THEN 1 ELSE 0 END) AS watchedEpisodesCount FROM Teebeez JOIN Episodes ON Teebeez.ID = Episodes.teebeeId WHERE Teebeez.tmdbId = %ld", [[NSDate date] timeIntervalSince1970], (long)tmdbId];
    sqlite3_stmt *statement;
    
    int prepare = sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil);
    
    if (prepare != SQLITE_OK) {
        NSLog(@"prepare: %d", prepare);
        if (prepare == SQLITE_ERROR) {
            NSLog(@"%s SQLITE_ERROR '%s' (%1d)", __FUNCTION__, sqlite3_errmsg(database), sqlite3_errcode(database));
        }
    }
    else {
        
        Teebee* teebee = nil;
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] initWithSqlStatement:statement];
            
            if (![dictionary[@"ID"] length]) {
                continue;
            }
            
            teebee = [[Teebee alloc] initWithDatabaseDictionary:[[NSMutableDictionary alloc] initWithSqlStatement:statement]];
            
            break;
        }
        sqlite3_finalize(statement);
        
        return teebee;
    }
    
    
    return nil;
}

- (BOOL)pullTeebeezEpisodesCount:(Teebee*)teebee {
    
    NSString *query = [NSString stringWithFormat:@"SELECT SUM(CASE WHEN Episodes.watched = '0' AND Episodes.airDate < %f THEN 1 ELSE 0 END) AS notWatchedEpisodesCount, SUM(CASE WHEN Episodes.watched = '1' THEN 1 ELSE 0 END) AS watchedEpisodesCount FROM (Teebeez JOIN Episodes ON Teebeez.ID = Episodes.teebeeId) WHERE Teebeez.ID = '%@'",[[NSDate date] timeIntervalSince1970], StringInteger((long)teebee.id)];
    sqlite3_stmt *statement;
    
    int prepare = sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil);
    
    if (prepare != SQLITE_OK) {
        NSLog(@"prepare: %d", prepare);
        if (prepare == SQLITE_ERROR) {
            NSLog(@"%s SQLITE_ERROR '%s' (%1d)", __FUNCTION__, sqlite3_errmsg(database), sqlite3_errcode(database));
        }
    }
    else {
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            [teebee addEpisodesCountFromDictionary:[[NSMutableDictionary alloc] initWithSqlStatement:statement]];
            
            break;
        }
        sqlite3_finalize(statement);
        
        return YES;
    }
    
    return NO;
    
}

- (BOOL)watchAllEpisodes:(BOOL)watch forTeebee:(Teebee*)teebee {
    
    NSString *query = [NSString stringWithFormat:@"UPDATE Episodes SET watched = '%d' WHERE teebeeId = %ld AND airDate < %f", watch, (long)teebee.id, [[NSDate date] timeIntervalSince1970]];
    sqlite3_stmt *statement;
    
    int prepare = sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil);
    
    if (prepare != SQLITE_OK) {
        NSLog(@"prepare: %d", prepare);
        if (prepare == SQLITE_ERROR) {
            NSLog(@"%s SQLITE_ERROR '%s' (%1d)", __FUNCTION__, sqlite3_errmsg(database), sqlite3_errcode(database));
        }
    }
    else {
        
        if (sqlite3_step(statement) == SQLITE_ROW) {
        }
        
        sqlite3_finalize(statement);
        
        return YES;
    }
    
    return NO;
    
}

- (BOOL)watchAllEpisodes:(BOOL)watch forTeebee:(Teebee*)teebee inSeason:(NSInteger)seasonNumber {
    
    NSString *query = [NSString stringWithFormat:@"UPDATE Episodes SET watched = '%d' WHERE teebeeId = %ld AND airDate < %f AND seasonNumber = '%ld'", watch, (long)teebee.id, [[NSDate date] timeIntervalSince1970], (long)seasonNumber];
    sqlite3_stmt *statement;
    
    int prepare = sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil);
    
    if (prepare != SQLITE_OK) {
        NSLog(@"prepare: %d", prepare);
        if (prepare == SQLITE_ERROR) {
            NSLog(@"%s SQLITE_ERROR '%s' (%1d)", __FUNCTION__, sqlite3_errmsg(database), sqlite3_errcode(database));
        }
    }
    else {
        
        if (sqlite3_step(statement) == SQLITE_ROW) {
        }
        
        sqlite3_finalize(statement);
        
        return YES;
    }
    
    return NO;
    
}

- (BOOL)watch:(BOOL)watch episode:(TeebeeEpisode*)episode forTeebee:(Teebee*)teebee {
    
    NSString *query = [NSString stringWithFormat:@"UPDATE Episodes SET watched = '%d' WHERE teebeeId = %ld AND episodeNumber = '%ld' AND seasonNumber = '%ld'", watch, (long)teebee.id, episode.episodeNumber, (long)episode.seasonNumber];
    sqlite3_stmt *statement;
    
    int prepare = sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil);
    
    if (prepare != SQLITE_OK) {
        NSLog(@"prepare: %d", prepare);
        if (prepare == SQLITE_ERROR) {
            NSLog(@"%s SQLITE_ERROR '%s' (%1d)", __FUNCTION__, sqlite3_errmsg(database), sqlite3_errcode(database));
        }
    }
    else {
        
        if (sqlite3_step(statement) == SQLITE_ROW) {
        }
        
        sqlite3_finalize(statement);
        
        return YES;
    }
    
    return NO;
    
}

- (BOOL)saveTeebee:(Teebee*)teebee {
    
    NSMutableDictionary* teebeeDictionary = teebee.databaseDictionary;
    
    if (teebee.id != -1) {
        
        if ([self updateDictionary:teebee.databaseDictionary intoTable:@"Teebeez" where:@{@"ID" : [NSString stringWithFormat:@"%ld", (long)teebee.id]}]) {
            return YES;
        }
        
    }
    
    NSInteger teebeeId = [self insertDictionary:teebeeDictionary intoTable:@"Teebeez"];
    
    teebee.id = teebeeId;
    
    if (teebeeId != -1) {
        [[NSNotificationCenter defaultCenter] postNotificationName:TeebeezDidReloadNotification object:nil userInfo:nil];
    }
    
    return (teebeeId != -1);
    
}

- (BOOL)pullSeasonsForTeebee:(Teebee*)teebee {
    
    NSString *query = [NSString stringWithFormat:@"SELECT seasonNumber, SUM(CASE WHEN watched = '1' THEN 1 ELSE 0 END) AS seasonWatchedEpisodes FROM Episodes WHERE teebeeId = '%@' GROUP BY seasonNumber",StringInteger((long)teebee.id)];
    sqlite3_stmt *statement;
    
    int prepare = sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil);
    
    if (prepare != SQLITE_OK) {
        NSLog(@"prepare: %d", prepare);
        if (prepare == SQLITE_ERROR) {
            NSLog(@"%s SQLITE_ERROR '%s' (%1d)", __FUNCTION__, sqlite3_errmsg(database), sqlite3_errcode(database));
        }
    }
    else {
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            if (!teebee.seasons) {
                teebee.seasons = [[NSMutableDictionary alloc] init];
            }
            
            NSMutableDictionary* seasonDictionary = [[NSMutableDictionary alloc] initWithSqlStatement:statement];
            teebee.seasons[seasonDictionary[@"seasonNumber"]] = @([seasonDictionary[@"seasonWatchedEpisodes"] integerValue]);
            
        }
        sqlite3_finalize(statement);
        
        return YES;
    }
    
    return NO;

}

- (BOOL)pullEpisodesForTeebee:(Teebee*)teebee inSeason:(NSInteger)seasonNumber {
    
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM Episodes WHERE teebeeId = '%@' AND seasonNumber = '%ld'",StringInteger((long)teebee.id), (long)seasonNumber];
    sqlite3_stmt *statement;
    
    int prepare = sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil);
    
    if (prepare != SQLITE_OK) {
        NSLog(@"prepare: %d", prepare);
        if (prepare == SQLITE_ERROR) {
            NSLog(@"%s SQLITE_ERROR '%s' (%1d)", __FUNCTION__, sqlite3_errmsg(database), sqlite3_errcode(database));
        }
    }
    else {
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            if (!teebee.episodes) {
                teebee.episodes = [[NSMutableDictionary alloc] init];
            }
            
            if (!teebee.episodes[StringInteger((long)seasonNumber)]) {
                teebee.episodes[StringInteger((long)seasonNumber)] = [[NSMutableDictionary alloc] init];
            }
            
            NSMutableDictionary* episodeDictionary = [[NSMutableDictionary alloc] initWithSqlStatement:statement];
            TeebeeEpisode* episode = [[TeebeeEpisode alloc] initWithDatabaseDictionary:episodeDictionary];
            teebee.episodes[StringInteger(seasonNumber)][StringInteger((long)episode.episodeNumber)] = episode;
            
        }
        sqlite3_finalize(statement);
        
        return YES;
    }
    
    return NO;
}

- (BOOL)deleteTeebee:(Teebee*)teebee {
    
    sqlite3_stmt *statement;
    
    NSString *query;
    
    int prepare;
    
    query = [NSString stringWithFormat:@"DELETE FROM Teebeez WHERE ID = '%@'",StringInteger((long)teebee.id)];
    
    prepare = sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil);
    
    if (prepare != SQLITE_OK) {
        NSLog(@"prepare: %d", prepare);
        if (prepare == SQLITE_ERROR) {
            NSLog(@"%s SQLITE_ERROR '%s' (%1d)", __FUNCTION__, sqlite3_errmsg(database), sqlite3_errcode(database));
        }
        return NO;
    }
    else {
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
        }
        sqlite3_finalize(statement);
    }
    
    query = [NSString stringWithFormat:@"DELETE FROM Episodes WHERE teebeeId = '%@'",StringInteger((long)teebee.id)];
    
    prepare = sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil);
    
    if (prepare != SQLITE_OK) {
        NSLog(@"prepare: %d", prepare);
        if (prepare == SQLITE_ERROR) {
            NSLog(@"%s SQLITE_ERROR '%s' (%1d)", __FUNCTION__, sqlite3_errmsg(database), sqlite3_errcode(database));
        }
//        return NO;
    }
    else {
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
        }
        sqlite3_finalize(statement);
    }
    

    
    teebee.id = -1;
    
    return YES;
}

- (NSInteger)lastSeasonOfTeebee:(Teebee*)teebee {
    
    NSString *query = [NSString stringWithFormat:@"SELECT seasonNumber FROM Episodes WHERE teebeeId = '%@' AND airDate = (SELECT max(airDate) FROM Episodes WHERE teebeeId = '%@' AND watched = '1')", StringInteger(teebee.id), StringInteger((long)teebee.id)];
    
    sqlite3_stmt *statement;
    
    int prepare = sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil);
    
    if (prepare != SQLITE_OK) {
        NSLog(@"prepare: %d", prepare);
        if (prepare == SQLITE_ERROR) {
            NSLog(@"%s SQLITE_ERROR '%s' (%1d)", __FUNCTION__, sqlite3_errmsg(database), sqlite3_errcode(database));
        }
    }
    else {
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            return [[[NSMutableDictionary alloc] initWithSqlStatement:statement][@"seasonNumber"] integerValue];
            
        }
        sqlite3_finalize(statement);
        
        
        return 1;
    }
    
    return 1;
    
}

- (void)pullNextExpisodeForTeebee:(Teebee*)teebee {
    
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];

    NSString *query = [NSString stringWithFormat:@"SELECT seasonNumber, episodeNumber, airDate FROM Episodes WHERE (airDate <> '(null)' AND airDate >= '%f' AND teebeeId = '%@') ORDER BY airDate ASC LIMIT 1", now, StringInteger((long)teebee.id)];
    
    sqlite3_stmt *statement;
    
    int prepare = sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil);
    
    if (prepare != SQLITE_OK) {
        NSLog(@"prepare: %d", prepare);
        if (prepare == SQLITE_ERROR) {
            NSLog(@"%s SQLITE_ERROR '%s' (%1d)", __FUNCTION__, sqlite3_errmsg(database), sqlite3_errcode(database));
        }
    }
    else {
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            teebee.nextEpisode = [[TeebeeEpisode alloc] initWithDatabaseDictionary:[[NSMutableDictionary alloc] initWithSqlStatement:statement]];
            
        }
        sqlite3_finalize(statement);
    }
    
}

- (TeebeeEpisode*)nextEpisodeToWatchForTeebee:(Teebee*)teebee {
    
    NSString *query = [NSString stringWithFormat:@"SELECT seasonNumber, episodeNumber, airDate FROM Episodes WHERE (airDate <> '(null)' AND watched = '0' AND teebeeId = '%@') ORDER BY airDate ASC LIMIT 1", StringInteger((long)teebee.id)];
    
    sqlite3_stmt *statement;
    
    TeebeeEpisode* episode = nil;
    
    int prepare = sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil);
    
    if (prepare != SQLITE_OK) {
        NSLog(@"prepare: %d", prepare);
        if (prepare == SQLITE_ERROR) {
            NSLog(@"%s SQLITE_ERROR '%s' (%1d)", __FUNCTION__, sqlite3_errmsg(database), sqlite3_errcode(database));
        }
    }
    else {
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            episode = [[TeebeeEpisode alloc] initWithDatabaseDictionary:[[NSMutableDictionary alloc] initWithSqlStatement:statement]];
            
        }
        sqlite3_finalize(statement);
    }
    
    return episode;
}

- (NSInteger)notWatchedEpisodesCount {
    
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    
    NSString *query = [NSString stringWithFormat:@"SELECT COUNT(*) AS c FROM Episodes WHERE (airDate <> '(null)' AND airDate <= '%f' AND watched = '0')", now];
    

    sqlite3_stmt *statement;
    
    NSInteger episodesCount = 0;
    
    int prepare = sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil);
    
    if (prepare != SQLITE_OK) {
        NSLog(@"prepare: %d", prepare);
        if (prepare == SQLITE_ERROR) {
            NSLog(@"%s SQLITE_ERROR '%s' (%1d)", __FUNCTION__, sqlite3_errmsg(database), sqlite3_errcode(database));
        }
    }
    else {
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            episodesCount = [[[NSMutableDictionary alloc] initWithSqlStatement:statement][@"c"] integerValue];
            
        }
        sqlite3_finalize(statement);
    }
    
    return episodesCount;
}

- (void)reloadTodayTeebeez {
    
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM (Teebeez JOIN Episodes ON Teebeez.ID = Episodes.teebeeId) WHERE (airDate <> '(null)' AND airDate >= '%f' AND airDate <= '%f' AND watched = '0') ",[[[NSDate date] resetToMidnight] timeIntervalSince1970], [[[NSDate date] resetToLateMidnight] timeIntervalSince1970]];
    
    query = @"SELECT * FROM Teebeez";

    sqlite3_stmt *statement;
    
    NSMutableArray* results = [[NSMutableArray alloc] init];
    
    int prepare = sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil);
    
    if (prepare != SQLITE_OK) {
        NSLog(@"prepare: %d", prepare);
        if (prepare == SQLITE_ERROR) {
            NSLog(@"%s SQLITE_ERROR '%s' (%1d)", __FUNCTION__, sqlite3_errmsg(database), sqlite3_errcode(database));
        }
    }
    else {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            NSMutableDictionary* item = [[NSMutableDictionary alloc] initWithSqlStatement:statement];
            
            item[@"posterPath"] = [ImageView imagePath:item[@"posterPath"] forWidth:92];
            
            [results addObject:item];
        }
        sqlite3_finalize(statement);
    }
    
    NSLog(@"path = %@", [[[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.moobeez"] URLByAppendingPathComponent:@"TodayShows.plist"]);
    
    [results writeToURL:[[[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.moobeez"] URLByAppendingPathComponent:@"TodayShows.plist"] atomically:YES];
    
    
    
}

@end
