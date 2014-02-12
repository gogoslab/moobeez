//
//  TmdbTvEpisode.h
//  Moobeez
//
//  Created by Radu Banea on 30/01/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDXML.h"

@interface TmdbTvEpisode : NSObject

@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* description;

@property (strong, nonatomic) NSString* posterPath;
@property (readwrite, nonatomic) NSInteger episodeNumber;
@property (readwrite, nonatomic) NSInteger seasonNumber;
@property (strong, nonatomic) NSDate* date;

- (id)initWithTmdbDictionary:(NSDictionary *)tmdbDictionary;
- (void)addEntriesFromTmdbDictionary:(NSDictionary *)tmdbDictionary;

- (id)initWithTvRageXmlElement:(DDXMLElement *)tvRageXmlElement;

@end
