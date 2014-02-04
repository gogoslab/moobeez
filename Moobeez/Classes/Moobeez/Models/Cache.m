//
//  Cache.m
//  Moobeez
//
//  Created by Radu Banea on 03/02/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "Cache.h"

@implementation Cache

static NSMutableDictionary* _cachedMovies;

+ (NSMutableDictionary*)cachedMovies {
    if (!_cachedMovies) {
        _cachedMovies = [[NSMutableDictionary alloc] init];
    }
    
    return _cachedMovies;
}

static NSMutableDictionary* _cachedTVs;

+ (NSMutableDictionary*)cachedTVs {
    if (!_cachedTVs) {
        _cachedTVs = [[NSMutableDictionary alloc] init];
    }
    
    return _cachedTVs;
}

static NSMutableDictionary* _cachedPersons;

+ (NSMutableDictionary*)cachedPersons {
    if (!_cachedPersons) {
        _cachedPersons = [[NSMutableDictionary alloc] init];
    }
    
    return _cachedPersons;
}

static NSMutableDictionary* _cachedSeasons;

+ (NSMutableDictionary*)cachedSeasons {
    if (!_cachedSeasons) {
        _cachedSeasons = [[NSMutableDictionary alloc] init];
    }
    
    return _cachedSeasons;
}

@end
