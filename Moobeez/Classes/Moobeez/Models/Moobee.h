//
//  Moobee.h
//  Moobeez
//
//  Created by Radu Banea on 10/14/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "Bee.h"

typedef enum MoobeeType {

    MoobeeNoneType = 0,
    MoobeeOnWatchlistType = 1,
    MoobeeSeenType = 2,

    MoobeeAllType,
    
    MoobeeFavoriteType = 0,

    MoobeeNewType = 4,
    MoobeeDiscardedType = 5
    
} MoobeeType;

@class TmdbMovie;

@interface Moobee : Bee

@property (readwrite, nonatomic) MoobeeType type;
@property (readwrite, nonatomic) BOOL isFavorite;
@property (strong, nonatomic) NSDate* releaseDate;

+ (id)moobeeWithTmdbMovie:(TmdbMovie*)movie;

@end
