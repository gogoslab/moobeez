//
//  TeebeeEpisode.m
//  Moobeez
//
//  Created by Radu Banea on 30/01/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "TeebeeEpisode.h"

@implementation TeebeeEpisode

- (id)initWithDatabaseDictionary:(NSDictionary*)databaseDictionary {
    
    self = [super initWithDatabaseDictionary:databaseDictionary];
    
    if (self) {
        
        self.seasonNumber = [databaseDictionary[@"seasonNumber"] integerValue];
        self.episodeNumber = [databaseDictionary[@"episodeNumber"] integerValue];

        self.watched = [databaseDictionary[@"watched"] boolValue];
        
        if (databaseDictionary[@"date"]) {
            self.date = [NSDate dateWithTimeIntervalSinceReferenceDate:[databaseDictionary[@"date"] doubleValue]];
        }
    }
    
    return self;
}

- (NSMutableDictionary*)databaseDictionary {
    
    NSMutableDictionary* databaseDictionary = [NSMutableDictionary dictionary];
    
    databaseDictionary[@"seasonNumber"] = [NSString stringWithFormat:@"%ld", (long)self.seasonNumber];
    databaseDictionary[@"episodeNumber"] = [NSString stringWithFormat:@"%ld", (long)self.episodeNumber];

    databaseDictionary[@"watched"] = [NSString stringWithFormat:@"%d", self.watched];
    
    if (self.date) {
        databaseDictionary[@"date"] = [NSString stringWithFormat:@"%.0f", [self.date timeIntervalSinceReferenceDate]];
    }
    
    return databaseDictionary;
}

@end
