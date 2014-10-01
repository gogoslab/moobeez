//
//  TimelineItem.m
//  Moobeez
//
//  Created by Radu Banea on 12/08/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "TimelineItem.h"
#import "Moobeez.h"

@interface TimelineItem ()

@end

@implementation TimelineItem

- (id)initWithDatabaseDictionary:(NSDictionary*)databaseDictionary {
    
    self = [super initWithDatabaseDictionary:databaseDictionary];
    
    if (self) {

        self.name = databaseDictionary[@"name"];
        self.backdropPath = databaseDictionary[@"backdropPath"];
        if (databaseDictionary[@"date"]) {
            if (databaseDictionary[@"episodeNumber"]) {
                self.date = [[NSDate dateWithTimeIntervalSince1970:[databaseDictionary[@"date"] doubleValue]] teebeeDisplayDate];
            }
            else {
                self.date = [NSDate dateWithTimeIntervalSince1970:[databaseDictionary[@"date"] doubleValue]];
            }
        }
        
        if (databaseDictionary[@"seasonNumber"]) {
            self.season = [databaseDictionary[@"seasonNumber"] integerValue];
        }
        else {
            self.season = -1;
        }
        
        if (databaseDictionary[@"episodeNumber"]) {
            self.episode = [databaseDictionary[@"episodeNumber"] integerValue];
        }
        
        self.tmdbId = [databaseDictionary[@"tmdbId"] integerValue];
        
        if (databaseDictionary[@"rating"]) {
            self.rating = [databaseDictionary[@"rating"] floatValue];
        }
        else {
            self.rating = -1;
        }

    }

    return self;
}

#pragma mark - Comparison selectors

- (NSComparisonResult)compareByDate:(TimelineItem*)timelineItem {
    return [self.date compare:timelineItem.date];
}

- (NSComparisonResult)compareDescByDate:(TimelineItem*)timelineItem {
    return [timelineItem.date compare:self.date];
}

- (NSComparisonResult)compareById:(TimelineItem*)timelineItem {
    return [[NSNumber numberWithInteger:timelineItem.id] compare:[NSNumber numberWithInteger:self.id]];
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[self class]]) {
        if (self.id == ((TimelineItem*) object).id) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)isMovie {
    return self.season == -1;
}

@end
