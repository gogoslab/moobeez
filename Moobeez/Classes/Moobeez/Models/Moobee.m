//
//  Moobee.m
//  Moobeez
//
//  Created by Radu Banea on 10/14/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "Moobee.h"
#import "Database.h"

@implementation Moobee

+ (id)initWithId:(NSInteger)id {
    return [[Database sharedDatabase] moobeeWithId:id];
}

- (id)initWithDictionary:(NSDictionary *)dictionary {
    
    self = [super initWithDictionary:dictionary];
    
    if (self) {

        self.tmdbId = [dictionary[@"tmdbId"] integerValue];
        self.name = dictionary[@"name"];
        self.comments = dictionary[@"comments"];
        self.posterPath = dictionary[@"posterPath"];
        self.rating = [dictionary[@"rating"] floatValue];
        self.date = [NSDate dateWithTimeIntervalSinceReferenceDate:[dictionary[@"date"] doubleValue]];
        self.type = [dictionary[@"type"] intValue];
        self.isFavorite = [dictionary[@"isFavorite"] boolValue];

    }

    return self;
}


@end
