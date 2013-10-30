//
//  Moobee.m
//  Moobeez
//
//  Created by Radu Banea on 10/14/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "Moobee.h"
#import "Moobeez.h"

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
        if (databaseDictionary[@"date"]) {
            self.date = [NSDate dateWithTimeIntervalSinceReferenceDate:[databaseDictionary[@"date"] doubleValue]];
        }
        self.type = [databaseDictionary[@"type"] intValue];
        self.isFavorite = [databaseDictionary[@"isFavorite"] boolValue];

    }

    return self;
}

- (NSMutableDictionary*)databaseDictionary {
    
    NSMutableDictionary* databaseDictionary = [NSMutableDictionary dictionary];
    
    databaseDictionary[@"tmdbId"] = [NSString stringWithFormat:@"%ld", self.tmdbId];
    databaseDictionary[@"name"] = [self.name stringByResolvingSQLIssues];
    databaseDictionary[@"comments"] = [self.name stringByResolvingSQLIssues];
    databaseDictionary[@"posterPath"] = [self.posterPath stringByResolvingSQLIssues];
    databaseDictionary[@"rating"] = [NSString stringWithFormat:@"%.1f", self.rating];
    if (self.date) {
        databaseDictionary[@"date"] = [NSString stringWithFormat:@"%.0f", [self.date timeIntervalSinceReferenceDate]];
    }
    databaseDictionary[@"type"] = [NSString stringWithFormat:@"%d", self.type];
    databaseDictionary[@"isFavorite"] = [NSString stringWithFormat:@"%d", self.isFavorite];
    
    return databaseDictionary;
}

- (BOOL)save {
    
    return [[Database sharedDatabase] saveMoobee:self];
    
}


@end
