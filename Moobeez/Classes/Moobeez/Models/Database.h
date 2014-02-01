//
//  Database.h
//  Moobeez
//
//  Created by Radu Banea on 10/14/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

#import "DatabaseItem.h"

#import "Bee.h"

#import "Moobee.h"

#import "Teebee.h"

#import "TmdbMovie.h"
#import "TmdbTV.h"
#import "TmdbPerson.h"
#import "TmdbImage.h"
#import "TmdbCharacter.h"
#import "TmdbTvSeason.h"
#import "TmdbTvEpisode.h"

#define DatabaseDidReloadNotification @"DidReloadDatabaseNotification"

@interface Database : NSObject {
    sqlite3 *database;
}

+ (Database*)sharedDatabase;
- (void)populateWithOldDatabase;
- (void)replaceOldDatabase;

- (NSMutableArray*)moobeezWithType:(MoobeeType)type;
- (NSMutableArray*)favoritesMoobeez;
- (Moobee*)moobeeWithId:(NSInteger)id;
- (Moobee*)moobeeWithTmdbId:(NSInteger)tmdbId;
- (BOOL)saveMoobee:(Moobee*)moobee;


- (NSMutableArray*)teebeezWithType:(TeebeeType)type;
- (Teebee*)teebeeWithId:(NSInteger)id;
- (Teebee*)teebeeWithTmdbId:(NSInteger)tmdbId;
- (BOOL)saveTeebee:(Teebee*)teebee;

@end
