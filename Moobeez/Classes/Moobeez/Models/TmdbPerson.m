//
//  TmdbPerson.m
//  Moobeez
//
//  Created by Radu Banea on 10/23/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "TmdbPerson.h"
#import "Moobeez.h"

@interface TmdbPerson ()

@property (readwrite, nonatomic) NSInteger id;

@end


@implementation TmdbPerson

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
    
    if ([[tmdbDictionary stringForKey:@"biography"] length]) {
        self.description = [tmdbDictionary stringForKey:@"biography"];
    }
    
    if ([[tmdbDictionary stringForKey:@"profile_path"] length]) {
        self.profilePath = [tmdbDictionary stringForKey:@"profile_path"];
    }
    
    if (tmdbDictionary[@"credits"][@"cast"]) {
        self.characters = [[NSMutableArray alloc] init];
        for (NSDictionary* castDictionary in tmdbDictionary[@"credits"][@"cast"]) {
            TmdbMovie* movie = [[TmdbMovie alloc] initWithTmdbDictionary:castDictionary];
            
            TmdbCharacter* character = [[TmdbCharacter alloc] init];
            character.name = castDictionary[@"character"];
            character.movie = movie;
            
            [self.characters addObject:character];
        }
    }
    
    if (tmdbDictionary[@"images"][@"profiles"]) {
        self.profileImages = [[NSMutableArray alloc] init];
        for (NSDictionary* imageDictionary in tmdbDictionary[@"images"][@"profiles"]) {
            TmdbImage* tmdbImage = [[TmdbImage alloc] initWithTmdbDictionary:imageDictionary];
            [self.profileImages addObject:tmdbImage];
        }
    }
    
    if (tmdbDictionary[@"imdb_id"]) {
        self.imdbId = tmdbDictionary[@"imdb_id"];
    }

    
}

@end
