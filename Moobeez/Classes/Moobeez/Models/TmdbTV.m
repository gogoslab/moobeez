//
//  TmdbTV.m
//  Moobeez
//
//  Created by Radu Banea on 30/01/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "TmdbTV.h"
#import "Moobeez.h"

@interface TmdbTV ()

@property (readwrite, nonatomic) NSInteger id;

@end

@implementation TmdbTV

- (id)initWithTmdbDictionary:(NSDictionary *)tmdbDictionary {
    
    self = [super init];
    
    if (self) {
        [self addEntriesFromTmdbDictionary:tmdbDictionary];
    }
    
    return self;
    
}

- (void)addEntriesFromTmdbDictionary:(NSDictionary *)tmdbDictionary {
    
    if (tmdbDictionary[@"id"]) {
        self.id = [tmdbDictionary[@"id"] integerValue];
    }
    
    if ([[tmdbDictionary stringForKey:@"name"] length]) {
        self.name = [tmdbDictionary stringForKey:@"name"];
    }
    
    if ([[tmdbDictionary stringForKey:@"overview"] length]) {
        self.description = [tmdbDictionary stringForKey:@"overview"];
    }
    
    if ([[tmdbDictionary stringForKey:@"poster_path"] length]) {
        self.posterPath = [tmdbDictionary stringForKey:@"poster_path"];
    }
    
    if ([[tmdbDictionary stringForKey:@"backdrop_path"] length]) {
        self.backdropPath = [tmdbDictionary stringForKey:@"backdrop_path"];
    }
    
    if (tmdbDictionary[@"credits"][@"cast"]) {
        self.characters = [[NSMutableArray alloc] init];
        for (NSDictionary* castDictionary in tmdbDictionary[@"credits"][@"cast"]) {
            TmdbPerson* person = [[TmdbPerson alloc] initWithTmdbDictionary:castDictionary];
            
            TmdbCharacter* character = [[TmdbCharacter alloc] init];
            character.name = [castDictionary stringForKey:@"character"];
            character.person = person;
            
            [self.characters addObject:character];
        }
    }

    if (tmdbDictionary[@"images"][@"backdrops"]) {
        self.backdropsImages = [[NSMutableArray alloc] init];
        for (NSDictionary* imageDictionary in tmdbDictionary[@"images"][@"backdrops"]) {
            TmdbImage* tmdbImage = [[TmdbImage alloc] initWithTmdbDictionary:imageDictionary];
            [self.backdropsImages addObject:tmdbImage];
        }
    }
    
    if (tmdbDictionary[@"images"][@"posters"]) {
        self.postersImages = [[NSMutableArray alloc] init];
        for (NSDictionary* imageDictionary in tmdbDictionary[@"images"][@"posters"]) {
            TmdbImage* tmdbImage = [[TmdbImage alloc] initWithTmdbDictionary:imageDictionary];
            [self.postersImages addObject:tmdbImage];
        }
    }
    
    if (tmdbDictionary[@"imdb_id"]) {
        self.imdbId = tmdbDictionary[@"imdb_id"];
    }
    
    if ([[tmdbDictionary stringForKey:@"first_air_date"] length]) {
        self.releaseDate = [[NSDateFormatter dateFormatterWithFormat:@"yyyy-MM-dd"] dateFromString:[tmdbDictionary stringForKey:@"first_air_date"]];
    }
    
    if (tmdbDictionary[@"in_production"]) {
        self.inProduction = [tmdbDictionary[@"in_production"] boolValue];
    }
    
    if (tmdbDictionary[@"status"]) {
        self.status = tmdbDictionary[@"status"];
    }
    
    if (tmdbDictionary[@"seasons"]) {
        self.seasons = [[NSMutableArray alloc] init];
        for (NSMutableDictionary* seasonsDictionary in tmdbDictionary[@"seasons"]) {
            TmdbTvSeason* season = [[TmdbTvSeason alloc] initWithTmdbDictionary:seasonsDictionary];
            if (season.seasonNumber > 0) {
                [self.seasons addObject:season];
            }
        }
    }
    
    if (tmdbDictionary[@"vote_average"]) {
        self.rating = [tmdbDictionary[@"vote_average"] floatValue];
    }
    
    if (tmdbDictionary[@"number_of_episodes"]) {
        self.episodesCount = [tmdbDictionary[@"number_of_episodes"] integerValue];
    }
    
    if (tmdbDictionary[@"number_of_seasons"]) {
        self.seasonsCount = [tmdbDictionary[@"number_of_seasons"] integerValue];
    }
    
    
}

#pragma mark - Comparison selectors

- (NSComparisonResult)compareByDate:(TmdbTV*)tv {
    return [tv.releaseDate compare:self.releaseDate];
}


@end
