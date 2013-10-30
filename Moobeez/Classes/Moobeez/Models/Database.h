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
#import "Moobee.h"

#import "TmdbMovie.h"
#import "TmdbPerson.h"
#import "TmdbImage.h"
#import "TmdbCharacter.h"

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
- (BOOL)saveMoobee:(Moobee*)moobee;

@end
