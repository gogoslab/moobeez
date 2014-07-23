//
//  TmdbPerson.h
//  Moobeez
//
//  Created by Radu Banea on 10/23/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TmdbPerson : NSObject

@property (readonly, nonatomic) NSInteger id;

@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* overview;
@property (strong, nonatomic) NSString* imdbId;

@property (strong, nonatomic) NSString* profilePath;

@property (strong, nonatomic) NSMutableArray* characters;

@property (strong, nonatomic) NSMutableArray* profileImages;

@property (readwrite, nonatomic) CGFloat popularity;

- (id)initWithTmdbDictionary:(NSDictionary *)tmdbDictionary;
- (void)addEntriesFromTmdbDictionary:(NSDictionary *)tmdbDictionary;

- (NSComparisonResult)compareByPopularity:(TmdbPerson*)person;

@end
