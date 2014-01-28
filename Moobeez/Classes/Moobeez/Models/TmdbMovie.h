//
//  TmdbMovie.h
//  Moobeez
//
//  Created by Radu Banea on 10/23/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "DatabaseItem.h"

typedef enum TmdbTrailerType {
    TmdbTrailerYoutubeType = 0,
    TmdbTrailerQuicktimeType = 1
    } TmdbTrailerType;

@interface TmdbMovie : DatabaseItem

@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* description;
@property (strong, nonatomic) NSString* imdbId;
@property (strong, nonatomic) NSString* trailerPath;
@property (readwrite, nonatomic) TmdbTrailerType trailerType;

@property (strong, nonatomic) NSMutableArray* characters;

@property (strong, nonatomic) NSMutableArray* backdropsImages;
@property (strong, nonatomic) NSMutableArray* postersImages;

@property (strong, nonatomic) NSString* posterPath;
@property (strong, nonatomic) NSString* backdropPath;

@property (strong, nonatomic) NSDate* releaseDate;

- (id)initWithTmdbDictionary:(NSDictionary *)tmdbDictionary;
- (void)addEntriesFromTmdbDictionary:(NSDictionary *)tmdbDictionary;

@end
