//
//  TmdbTvSeason.h
//  Moobeez
//
//  Created by Radu Banea on 30/01/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TmdbTvSeason : NSObject

@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* overview;

@property (strong, nonatomic) NSString* posterPath;
@property (readwrite, nonatomic) NSInteger seasonNumber;
@property (strong, nonatomic) NSDate* date;

@property (strong, nonatomic) NSMutableArray* episodes;

- (id)initWithTmdbDictionary:(NSDictionary *)tmdbDictionary;
- (void)addEntriesFromTmdbDictionary:(NSDictionary *)tmdbDictionary;

@end
