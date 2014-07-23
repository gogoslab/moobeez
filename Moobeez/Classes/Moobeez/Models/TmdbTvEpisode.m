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
        self.overview = tmdbDictionary[@"overview"];
    }
    
}

- (id)initWithTvRageXmlElement:(DDXMLElement *)tvRageXmlElement {
    
    self = [super init];
    
    if (self) {
        NSLog(@"el: %@", tvRageXmlElement);
        
        if ([[tvRageXmlElement elementsForName:@"airdate"] count]) {
            NSString* dateString = [[tvRageXmlElement elementsForName:@"airdate"][0] stringValue];
            self.date = [[NSDateFormatter dateFormatterWithFormat:@"yyyy-MM-dd"] dateFromString:dateString];
        }
        
        if ([[tvRageXmlElement elementsForName:@"epnum"] count]) {
            self.episodeNumber = [[[tvRageXmlElement elementsForName:@"epnum"][0] stringValue] integerValue];
        }
        
        if ([[tvRageXmlElement elementsForName:@"seasonnum"] count]) {
            self.seasonNumber = [[[tvRageXmlElement elementsForName:@"seasonnum"][0] stringValue] integerValue];
        }
        
        if ([[tvRageXmlElement elementsForName:@"title"] count]) {
            self.name = [[tvRageXmlElement elementsForName:@"title"][0] stringValue];
        }
    }
    
    return self;
}

@end
