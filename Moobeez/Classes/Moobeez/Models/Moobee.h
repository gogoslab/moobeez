//
//  Moobee.h
//  Moobeez
//
//  Created by Radu Banea on 10/14/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "DatabaseItem.h"

typedef enum MoobeeType {

    MoobeeNoneType = 0,
    MoobeeOnWatchlistType = 1,
    MoobeeSeenType = 2,

    MoobeeAllType,
    
    MoobeeFavoriteType = 0
    
} MoobeeType;

@class TmdbMovie;

@interface Moobee : DatabaseItem

@property (readwrite, nonatomic) NSInteger id;

@property (readwrite, nonatomic) NSInteger tmdbId;
@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* comments;
@property (strong, nonatomic) NSString* posterPath;
@property (readwrite, nonatomic) CGFloat rating;
@property (strong, nonatomic) NSDate* date;
@property (readwrite, nonatomic) MoobeeType type;
@property (readwrite, nonatomic) BOOL isFavorite;

@property (readonly, nonatomic) NSMutableDictionary* databaseDictionary;

+ (id)moobeeWithTmdbMovie:(TmdbMovie*)movie;

- (NSComparisonResult)compareByDate:(Moobee*)moobee;
- (NSComparisonResult)compareById:(Moobee*)moobee;

@end
