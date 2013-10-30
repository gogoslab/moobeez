//
//  DatabaseItem.h
//  Moobeez
//
//  Created by Radu Banea on 10/14/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface DatabaseItem : NSObject

@property (readonly, nonatomic) NSInteger id;

+ (id)initWithId:(NSInteger)id;
- (id)initWithDatabaseDictionary:(NSDictionary*)databaseDictionary;

- (BOOL)save;

@end
