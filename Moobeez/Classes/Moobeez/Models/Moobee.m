//
//  Moobee.m
//  Moobeez
//
//  Created by Radu Banea on 10/14/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "Moobee.h"
#import "Database.h"

@implementation Moobee

+ (id)initWithId:(NSInteger)id {
    return [[Database sharedDatabase] moobeeWithId:id];
}

- (id)initWithDatabaseDictionary:(NSDictionary*)databaseDictionary {
    
    self = [super initWithDatabaseDictionary:databaseDictionary];
    
    if (self) {

        self.tmdbId = [databaseDictionary[@"tmdbId"] integerValue];
        self.name = databaseDictionary[@"name"];
        self.comments = databaseDictionary[@"comments"];
        self.posterPath = databaseDictionary[@"posterPath"];
        self.rating = [databaseDictionary[@"rating"] floatValue];
        self.date = [NSDate dateWithTimeIntervalSinceReferenceDate:[databaseDictionary[@"date"] doubleValue]];
        self.type = [databaseDictionary[@"type"] intValue];
        self.isFavorite = [databaseDictionary[@"isFavorite"] boolValue];

    }

    return self;
}


@end
