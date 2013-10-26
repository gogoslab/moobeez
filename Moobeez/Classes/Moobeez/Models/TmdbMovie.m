//
//  TmdbMovie.m
//  Moobeez
//
//  Created by Radu Banea on 10/23/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "TmdbMovie.h"
#import "Moobeez.h"

@interface TmdbMovie ()

@property (readwrite, nonatomic) NSInteger id;

@end

@implementation TmdbMovie

- (id)initWithDatabaseDictionary:(NSDictionary *)databaseDictionary {
    
    self = [super initWithDatabaseDictionary:databaseDictionary];
    
    if (self) {
        
        self.name = databaseDictionary[@"name"];
        self.description = databaseDictionary[@"description"];
        self.imdbId = databaseDictionary[@"imdbId"];
        self.trailerPath = databaseDictionary[@"trailerPath"];
        self.trailerType = [databaseDictionary[@"trailerType"] integerValue];
    }
    return self;
}

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
    
    if ([[tmdbDictionary stringForKey:@"title"] length]) {
        self.name = [tmdbDictionary stringForKey:@"title"];
    }
    
    if ([[tmdbDictionary stringForKey:@"overview"] length]) {
        self.description = [tmdbDictionary stringForKey:@"overview"];
    }
    
    if ([[tmdbDictionary stringForKey:@"poster_path"] length]) {
        self.posterPath = [tmdbDictionary stringForKey:@"poster_path"];
    }

    if (tmdbDictionary[@"casts"][@"cast"]) {
        self.characters = [[NSMutableArray alloc] init];
        for (NSDictionary* castDictionary in tmdbDictionary[@"casts"][@"cast"]) {
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
    
    self.trailerPath = nil;
    
    for (NSDictionary* trailerDictionary in tmdbDictionary[@"trailers"][@"quicktime"]) {
        
        for (NSDictionary* sourceDictionary in trailerDictionary[@"sources"]) {
            if ([sourceDictionary[@"size"] isEqualToString:@"720p"]) {
                self.trailerPath = sourceDictionary[@"source"];
                self.trailerType = TmdbTrailerQuicktimeType;
                break;
            }
            
            if ([sourceDictionary[@"size"] isEqualToString:@"480p"] && !self.trailerPath) {
                self.trailerPath = sourceDictionary[@"source"];
                self.trailerType = TmdbTrailerQuicktimeType;
            }
        }
    }
    
    if (!self.trailerPath && [tmdbDictionary[@"trailers"][@"youtube"] count]) {
        self.trailerPath = tmdbDictionary[@"trailers"][@"youtube"][0][@"source"];
        self.trailerType = TmdbTrailerYoutubeType;
    }
    
    if ([[tmdbDictionary stringForKey:@"release_date"] length]) {
        self.releaseDate = [[NSDateFormatter dateFormatterWithFormat:@"yyyy-MM-dd"] dateFromString:[tmdbDictionary stringForKey:@"release_date"]];
    }
    
}

@end
