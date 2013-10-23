//
//  TmdbPerson.h
//  Moobeez
//
//  Created by Radu Banea on 10/23/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "DatabaseItem.h"

@interface TmdbPerson : DatabaseItem

@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* description;
@property (strong, nonatomic) NSString* imdbId;

@property (strong, nonatomic) NSString* profilePath;

@property (strong, nonatomic) NSMutableArray* characters;

@property (strong, nonatomic) NSMutableArray* profileImages;

- (id)initWithTmdbDictionary:(NSDictionary *)tmdbDictionary;
- (void)addEntriesFromTmdbDictionary:(NSDictionary *)tmdbDictionary;

@end
