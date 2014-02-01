//
//  Bee.m
//  Moobeez
//
//  Created by Radu Banea on 10/14/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "Bee.h"
#import "Moobeez.h"

@interface Bee ()

@end

@implementation Bee

- (id)initWithDatabaseDictionary:(NSDictionary*)databaseDictionary {
    
    self = [super initWithDatabaseDictionary:databaseDictionary];
    
    if (self) {

        self.tmdbId = [databaseDictionary[@"tmdbId"] integerValue];
        self.name = databaseDictionary[@"name"];
        self.comments = databaseDictionary[@"comments"];
        self.posterPath = databaseDictionary[@"posterPath"];
        self.rating = [databaseDictionary[@"rating"] floatValue];
        if (databaseDictionary[@"date"]) {
            self.date = [NSDate dateWithTimeIntervalSinceReferenceDate:[databaseDictionary[@"date"] doubleValue]];
        }
    }

    return self;
}

- (NSMutableDictionary*)databaseDictionary {
    
    NSMutableDictionary* databaseDictionary = [NSMutableDictionary dictionary];
    
    databaseDictionary[@"tmdbId"] = [NSString stringWithFormat:@"%ld", (long)self.tmdbId];
    databaseDictionary[@"name"] = [self.name stringByResolvingSQLIssues];
    databaseDictionary[@"comments"] = [self.comments stringByResolvingSQLIssues];
    databaseDictionary[@"posterPath"] = [self.posterPath stringByResolvingSQLIssues];
    databaseDictionary[@"rating"] = [NSString stringWithFormat:@"%.1f", self.rating];
    if (self.date) {
        databaseDictionary[@"date"] = [NSString stringWithFormat:@"%.0f", [self.date timeIntervalSinceReferenceDate]];
    }
    
    return databaseDictionary;
}

#pragma mark - Comparison selectors

- (NSComparisonResult)compareByDate:(Bee*)bee {
    return [bee.date compare:self.date];
}

- (NSComparisonResult)compareById:(Bee*)bee {
    return [[NSNumber numberWithInteger:bee.id] compare:[NSNumber numberWithInteger:self.id]];
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[self class]]) {
        if (self.id == ((Bee*) object).id) {
            return YES;
        }
    }
    
    return NO;
}


@end
