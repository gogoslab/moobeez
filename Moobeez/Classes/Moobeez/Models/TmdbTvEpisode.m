//
//  TmdbTvEpisode.m
//  Moobeez
//
//  Created by Radu Banea on 30/01/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "TmdbTvEpisode.h"
#import "Moobeez.h"

@implementation TmdbTvEpisode

- (id)initWithTmdbDictionary:(NSDictionary *)tmdbDictionary {
    self = [super init];
    
    if (self) {
        [self addEntriesFromTmdbDictionary:tmdbDictionary];
    }
    
    return self;
}

- (void)addEntriesFromTmdbDictionary:(NSDictionary *)tmdbDictionary {
    
    if (tmdbDictionary[@"still_path"] && [tmdbDictionary isKindOfClass:[NSString class]]) {
        self.posterPath = tmdbDictionary[@"still_path"];
    }
    
    if (tmdbDictionary[@"air_date"]) {
        self.date = [[NSDateFormatter dateFormatterWithFormat:@"yyyy-MM-dd"] dateFromString:[tmdbDictionary stringForKey:@"air_date"]];
    }
    
    if (tmdbDictionary[@"episode_number"]) {
        self.episodeNumber = [tmdbDictionary[@"episode_number"] integerValue];
    }
    
    if (tmdbDictionary[@"name"]) {
        self.name = tmdbDictionary[@"name"];
    }
    
    if (tmdbDictionary[@"overview"]) {
        self.description = tmdbDictionary[@"overview"];
    }
    
}

@end
