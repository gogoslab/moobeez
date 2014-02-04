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

- (id)init {
    self = [super init];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:CURRENT_DATABASE_PATH]) {
        NSString *sqLiteDb = [[NSBundle mainBundle] pathForResource:@"MoobeezDatabase"
                                                             ofType:@""];
    
        NSError* error = nil;
        
        [[NSFileManager defaultManager] copyItemAtPath:sqLiteDb toPath:CURRENT_DATABASE_PATH error:&error];
        
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

- (void)dealloc {
    sqlite3_close(database);
}

#pragma mark - General Methods

- (NSInteger)insertDictionary:(NSDictionary*)dictionary intoTable:(NSString*)table {
    
    sqlite_int64 nextId = [self generateNewId];

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
    
    for (NSDictionary* dictionary in objects) {

        sqlite_int64 nextId = [self generateNewId];

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
        
        if ([self updateDictionary:moobee.databaseDictionary intoTable:@"Moobeez" where:@{@"ID" : [NSString stringWithFormat:@"%ld", moobee.id]}]) {
            return YES;
        }
        
    }
    
    NSInteger moobeeId = [self insertDictionary:moobeeDictionary intoTable:@"Moobeez"];
    
    moobee.id = moobeeId;
    
    if (moobeeId != -1) {
        [[NSNotificationCenter defaultCenter] postNotificationName:DatabaseDidReloadNotification object:nil userInfo:nil];
    }
    
    return (moobeeId != -1);
    
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
            query = [NSString stringWithFormat:@"SELECT Teebeez.*, e1.* FROM Teebeez JOIN Episodes e1 ON (Teebeez.ID = e1.teebeeId AND e1.airDate > %f) LEFT OUTER JOIN Episodes e2 ON (Teebeez.ID = e2.teebeeId AND (e1.airDate < e2.airDate OR e1.airDate = e2.airDate AND e1.id < e2.id)) GROUP BY e1.teebeeId", now];
            break;
        default:
            query = [NSString stringWithFormat:@"SELECT Teebeez.*, SUM(CASE WHEN Episodes.watched = '0' THEN 1 ELSE 0 END) AS notWatchedEpisodesCount, SUM(CASE WHEN Episodes.watched = '1' THEN 1 ELSE 0 END) AS watchedEpisodesCount FROM Teebeez JOIN Episodes ON (Teebeez.ID = Episodes.teebeeId) GROUP BY Teebeez.ID ORDER BY Teebeez.ID DESC"];
            break;
    }
    
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
    
    NSString *query = [NSString stringWithFormat:@"SELECT * ,SUM(CASE WHEN Episodes.watched = '0' THEN 1 ELSE 0 END) AS notWatchedEpisodesCount, SUM(CASE WHEN Episodes.watched = '1' THEN 1 ELSE 0 END) AS watchedEpisodesCount FROM Teebeez WHERE ID = %ld", (long)id];
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil)
        == SQLITE_OK) {
        
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
    
    NSString *query = [NSString stringWithFormat:@"SELECT * , SUM(CASE WHEN Episodes.watched = '0' THEN 1 ELSE 0 END) AS notWatchedEpisodesCount, SUM(CASE WHEN Episodes.watched = '1' THEN 1 ELSE 0 END) AS watchedEpisodesCount FROM Teebeez WHERE tmdbId = %ld", (long)tmdbId];
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil)
        == SQLITE_OK) {
        
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

- (BOOL)pullTeebeezEpisodesCount:(Teebee*)teebee {
    
    NSString *query = [NSString stringWithFormat:@"SELECT SUM(CASE WHEN Episodes.watched = '0' THEN 1 ELSE 0 END) AS notWatchedEpisodesCount, SUM(CASE WHEN Episodes.watched = '1' THEN 1 ELSE 0 END) AS watchedEpisodesCount FROM Teebeez WHERE ID = %ld", (long)teebee.id];
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil)
        == SQLITE_OK) {
        
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
    
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil)
        == SQLITE_OK) {
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
        }
        sqlite3_finalize(statement);
        
        return YES;
    }
    
    return NO;
    
}

- (BOOL)saveTeebee:(Teebee*)teebee {
    
    NSMutableDictionary* teebeeDictionary = teebee.databaseDictionary;
    
    if (teebee.id != -1) {
        
        if ([self updateDictionary:teebee.databaseDictionary intoTable:@"Teebeez" where:@{@"ID" : [NSString stringWithFormat:@"%ld", teebee.id]}]) {
            return YES;
        }
        
    }
    
    NSInteger teebeeId = [self insertDictionary:teebeeDictionary intoTable:@"Teebeez"];
    
    teebee.id = teebeeId;
    
    if (teebeeId != -1) {
        [[NSNotificationCenter defaultCenter] postNotificationName:DatabaseDidReloadNotification object:nil userInfo:nil];
    }
    
    return (teebeeId != -1);
    
}

@end
