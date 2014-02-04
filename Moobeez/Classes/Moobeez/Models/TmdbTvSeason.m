//
//  TmdbTvSeason.m
//  Moobeez
//
//  Created by Radu Banea on 30/01/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "TmdbTvSeason.h"
#import "Moobeez.h"

@implementation TmdbTvSeason

- (id)initWithTmdbDictionary:(NSDictionary *)tmdbDictionary {
    self = [super init];
    
    if (self) {
        [self addEntriesFromTmdbDictionary:tmdbDictionary];
    }
    
    return self;
}

- (void)addEntriesFromTmdbDictionary:(NSDictionary *)tmdbDictionary {
    
    if (tmdbDictionary[@"poster_path"]) {
        self.posterPath = tmdbDictionary[@"poster_path"];
    }

    if (tmdbDictionary[@"air_date"] && [tmdbDictionary[@"air_date"] isKindOfClass:[NSString class]]) {
        self.date = [[NSDateFormatter dateFormatterWithFormat:@"yyyy-MM-dd"] dateFromString:tmdbDictionary[@"air_date"]];
    }

    if (tmdbDictionary[@"season_number"]) {
        self.seasonNumber = [tmdbDictionary[@"season_number"] integerValue];
    }

    if (tmdbDictionary[@"name"]) {
        self.name = tmdbDictionary[@"name"];
    }
    
    if (tmdbDictionary[@"overview"]) {
        self.description = tmdbDictionary[@"overview"];
    }

    if (tmdbDictionary[@"episodes"]) {
        self.episodes = [[NSMutableArray alloc] init];
        for (NSMutableDictionary* episodeDictionary in tmdbDictionary[@"episodes"]) {
            [self.episodes addObject:[[TmdbTvEpisode alloc] initWithTmdbDictionary:episodeDictionary]];
        }
    }
}

@end
