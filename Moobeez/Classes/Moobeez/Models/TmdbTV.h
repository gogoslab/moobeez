//
//  TmdbTV.h
//  Moobeez
//
//  Created by Radu Banea on 30/01/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TmdbTV : NSObject

@property (readonly, nonatomic) NSInteger id;

@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* description;
@property (strong, nonatomic) NSString* imdbId;
@property (strong, nonatomic) NSString* tvRageId;

@property (strong, nonatomic) NSMutableArray* characters;

@property (strong, nonatomic) NSMutableArray* backdropsImages;
@property (strong, nonatomic) NSMutableArray* postersImages;

@property (strong, nonatomic) NSString* posterPath;
@property (strong, nonatomic) NSString* backdropPath;

@property (strong, nonatomic) NSDate* releaseDate;

@property (readwrite, nonatomic) BOOL inProduction;
@property (strong, nonatomic) NSString* status;

@property (readwrite, nonatomic) CGFloat rating;

@property (strong, nonatomic) NSMutableArray* seasons;

@property (readwrite, nonatomic) NSInteger episodesCount;
@property (readwrite, nonatomic) NSInteger seasonsCount;


- (id)initWithTmdbDictionary:(NSDictionary *)tmdbDictionary;
- (void)addEntriesFromTmdbDictionary:(NSDictionary *)tmdbDictionary;

@end
