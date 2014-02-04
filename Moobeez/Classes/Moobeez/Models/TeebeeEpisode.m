//
//  TeebeeEpisode.m
//  Moobeez
//
//  Created by Radu Banea on 30/01/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "TeebeeEpisode.h"

@interface TeebeeEpisode ()

@end

@implementation TeebeeEpisode

- (id)init {
    
    self = [super init];
    
    if (self) {
        self.id = -1;
    }
    
    return self;
}

- (id)initWithDatabaseDictionary:(NSDictionary*)databaseDictionary {
    
    self = [super initWithDatabaseDictionary:databaseDictionary];
    
    if (self) {
        
        self.seasonNumber = [databaseDictionary[@"seasonNumber"] integerValue];
        self.episodeNumber = [databaseDictionary[@"episodeNumber"] integerValue];

        self.watched = [databaseDictionary[@"watched"] boolValue];
        
        if (databaseDictionary[@"airDate"]) {
            self.airDate = [NSDate dateWithTimeIntervalSinceReferenceDate:[databaseDictionary[@"airDate"] doubleValue]];
        }
    }
    
    return self;
}

- (NSMutableDictionary*)databaseDictionary {
    
    NSMutableDictionary* databaseDictionary = [NSMutableDictionary dictionary];
    
    databaseDictionary[@"seasonNumber"] = [NSString stringWithFormat:@"%ld", (long)self.seasonNumber];
    databaseDictionary[@"episodeNumber"] = [NSString stringWithFormat:@"%ld", (long)self.episodeNumber];

    databaseDictionary[@"watched"] = [NSString stringWithFormat:@"%d", self.watched];
    
    if (self.airDate) {
        databaseDictionary[@"airDate"] = [NSString stringWithFormat:@"%.0f", [self.airDate timeIntervalSince1970]];
    }
    
    return databaseDictionary;
}

@end
