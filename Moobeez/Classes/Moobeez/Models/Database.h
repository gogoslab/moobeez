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

@interface Database : NSObject {
    sqlite3 *database;
}

+ (Database*)sharedDatabase;
- (void)populateWithOldDatabase:(NSArray*)oldDatabase;

- (NSMutableArray*)moobeezWithType:(MoobeeType)type;
- (Moobee*)moobeeWithId:(NSInteger)id;

@end
