//
//  Cache.h
//  Moobeez
//
//  Created by Radu Banea on 03/02/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Cache : NSObject

+ (NSMutableDictionary*)cachedMovies;
+ (NSMutableDictionary*)cachedTVs;
+ (NSMutableDictionary*)cachedPersons;
+ (NSMutableDictionary*)cachedSeasons;

@end
