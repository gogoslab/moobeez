//
//  TmdbImage.m
//  Moobeez
//
//  Created by Radu Banea on 10/23/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "TmdbImage.h"

@implementation TmdbImage

- (id)initWithTmdbDictionary:(NSDictionary *)tmdbDictionary {
    self = [super init];
    
    if (self) {
        [self addEntriesFromTmdbDictionary:tmdbDictionary];
    }
    
    return self;
}

- (void)addEntriesFromTmdbDictionary:(NSDictionary *)tmdbDictionary {
    
    self.path = tmdbDictionary[@"file_path"];
    self.aspectRatio = [tmdbDictionary[@"aspect_ratio"] floatValue];
    
}

@end
