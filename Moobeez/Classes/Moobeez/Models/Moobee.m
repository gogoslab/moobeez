//
//  Moobee.m
//  Moobeez
//
//  Created by Radu Banea on 10/14/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "Moobee.h"
#import "Moobeez.h"

@interface Moobee ()

@end

@implementation Moobee

+ (id)initWithId:(NSInteger)id {
    return [[Database sharedDatabase] moobeeWithId:id];
}

- (id)initWithDatabaseDictionary:(NSDictionary*)databaseDictionary {
    
    self = [super initWithDatabaseDictionary:databaseDictionary];
    
    if (self) {

        self.type = [databaseDictionary[@"type"] intValue];
        self.isFavorite = [databaseDictionary[@"isFavorite"] boolValue];
        if (databaseDictionary[@"releaseDate"]) {
            self.releaseDate = [NSDate dateWithTimeIntervalSince1970:[databaseDictionary[@"releaseDate"] doubleValue]];
        }

    }

    return self;
}

- (NSMutableDictionary*)databaseDictionary {
    
    NSMutableDictionary* databaseDictionary = super.databaseDictionary;
    
    databaseDictionary[@"type"] = [NSString stringWithFormat:@"%d", self.type];
    databaseDictionary[@"isFavorite"] = [NSString stringWithFormat:@"%d", self.isFavorite];

    if (self.releaseDate) {
        databaseDictionary[@"releaseDate"] = [NSString stringWithFormat:@"%.0f", [self.releaseDate timeIntervalSince1970]];
    }
    
    return databaseDictionary;
}

+ (id)moobeeWithTmdbMovie:(TmdbMovie*)movie {
    Moobee* moobee = [[Database sharedDatabase] moobeeWithTmdbId:movie.id];
    
    if (moobee) {
        return moobee;
    }
    
    moobee = [[Moobee alloc] init];
    
    if (moobee) {
        moobee.name = movie.name;
        moobee.tmdbId = movie.id;
        moobee.posterPath = movie.posterPath;
        moobee.backdropPath = movie.backdropPath;
        moobee.comments = @"";
        moobee.releaseDate = movie.releaseDate;
        moobee.id = -1;
    }
    
    return moobee;
}

- (BOOL)save {
    
    return [[Database sharedDatabase] saveMoobee:self];
    
}

@end
