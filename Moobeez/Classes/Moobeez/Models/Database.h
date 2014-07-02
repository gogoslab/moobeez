//
//  Database.h
//  Moobeez
//
//  Created by Radu Banea on 10/14/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

#import "DatabaseHeaders.h"

#define DatabaseDidReloadNotification @"DidReloadDatabaseNotification"
#define MoobeezDidReloadNotification @"MoobeezDidReloadNotification"
#define TeebeezDidReloadNotification @"TeebeezDidReloadNotification"

@interface Database : NSObject {
    sqlite3 *database;
}

+ (Database*)sharedDatabase;

- (id)initWithPath:(NSString*)path placeholderPath:(NSString*)placeholderPath;

- (void)populateWithOldDatabase;
- (void)replaceOldDatabase;

- (NSMutableArray*)moobeezWithType:(MoobeeType)type;
- (NSMutableArray*)favoritesMoobeez;
- (Moobee*)moobeeWithId:(NSInteger)id;
- (Moobee*)moobeeWithTmdbId:(NSInteger)tmdbId;
- (BOOL)saveMoobee:(Moobee*)moobee;
- (BOOL)deleteMoobee:(Moobee*)moobee;

- (NSMutableArray*)teebeezWithType:(TeebeeType)type;
- (NSMutableArray*)teebeezToUpdate;
- (Teebee*)teebeeWithId:(NSInteger)id;
- (Teebee*)teebeeWithTmdbId:(NSInteger)tmdbId;
- (BOOL)pullTeebeezEpisodesCount:(Teebee*)teebee;
- (BOOL)watchAllEpisodes:(BOOL)watch forTeebee:(Teebee*)teebee;
- (BOOL)watchAllEpisodes:(BOOL)watch forTeebee:(Teebee*)teebee inSeason:(NSInteger)seasonNumber;
- (BOOL)watch:(BOOL)watch episode:(TeebeeEpisode*)episode forTeebee:(Teebee*)teebee;
- (BOOL)saveTeebee:(Teebee*)teebee;
- (BOOL)pullSeasonsForTeebee:(Teebee*)teebee;
- (BOOL)pullEpisodesForTeebee:(Teebee*)teebee inSeason:(NSInteger)seasonNumber;
- (BOOL)deleteTeebee:(Teebee*)teebee;
- (NSInteger)lastSeasonOfTeebee:(Teebee*)teebee;
- (void)pullNextExpisodeForTeebee:(Teebee*)teebee;
- (TeebeeEpisode*)nextEpisodeToWatchForTeebee:(Teebee*)teebee;
- (NSInteger)notWatchedEpisodesCount;

- (NSMutableArray*)insertObjects:(NSArray*)objects atKeys:(NSArray*)keys intoTable:(NSString*)table;
- (BOOL)updateColumnValues:(NSArray*)values forColumn:(NSString*)column intoTable:(NSString*)table forIds:(NSArray*)ids;

- (void)clearTable:(NSString*)tableName;

- (void)reloadTodayTeebeez;

- (NSMutableArray*)executeQuery:(NSString*)query;
@end
