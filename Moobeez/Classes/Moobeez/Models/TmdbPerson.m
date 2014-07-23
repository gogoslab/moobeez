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
        self.overview = [tmdbDictionary stringForKey:@"biography"];
    }
    
    if ([[tmdbDictionary stringForKey:@"profile_path"] length]) {
        self.profilePath = [tmdbDictionary stringForKey:@"profile_path"];
    }
    
    if (tmdbDictionary[@"combined_credits"][@"cast"]) {
        self.characters = [[NSMutableArray alloc] init];
        for (NSDictionary* castDictionary in tmdbDictionary[@"combined_credits"][@"cast"]) {
            TmdbCharacter* character = [[TmdbCharacter alloc] init];
            character.name = [castDictionary stringForKey:@"character"];

            if ([castDictionary[@"media_type"] isEqualToString:@"movie"]) {
                TmdbMovie* movie = [[TmdbMovie alloc] initWithTmdbDictionary:castDictionary];
                character.movie = movie;
            }
            else {
                TmdbTV* tv = [[TmdbTV alloc] initWithTmdbDictionary:castDictionary];
                character.tv = tv;
            }
            
            [self.characters addObject:character];
        }
        
        [self.characters sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            
            NSDate* firstDate = (((TmdbCharacter*) obj1).movie ? ((TmdbCharacter*) obj1).movie.releaseDate : ((TmdbCharacter*) obj1).tv.releaseDate);
            NSDate* secondDate = (((TmdbCharacter*) obj2).movie ? ((TmdbCharacter*) obj2).movie.releaseDate : ((TmdbCharacter*) obj2).tv.releaseDate);
            
            return [secondDate compare:firstDate];
        }];
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

    if (tmdbDictionary[@"popularity"]) {
        self.popularity = [tmdbDictionary[@"popularity"] floatValue];
    }

}

#pragma mark - Comparison selectors

- (NSComparisonResult)compareByPopularity:(TmdbPerson*)person {
    return [@(person.popularity) compare:@(self.popularity)];
}

@end
