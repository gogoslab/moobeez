//
//  Teebee.m
//  Moobeez
//
//  Created by Radu Banea on 30/01/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "Teebee.h"
#import "Moobeez.h"

@implementation Teebee

+ (id)initWithId:(NSInteger)id {
    return [[Database sharedDatabase] moobeeWithId:id];
}

- (id)initWithDatabaseDictionary:(NSDictionary*)databaseDictionary {
    
    self = [super initWithDatabaseDictionary:databaseDictionary];
    
    if (self) {
        self.type = [databaseDictionary[@"type"] intValue];
    }
    
    return self;
}

- (NSMutableDictionary*)databaseDictionary {
    
    NSMutableDictionary* databaseDictionary = super.databaseDictionary;
    
    databaseDictionary[@"type"] = [NSString stringWithFormat:@"%d", self.type];
    
    return databaseDictionary;
}

+ (id)teebeeWithTmdbTV:(TmdbTV*)tv {
    Teebee* teebee = [[Database sharedDatabase] teebeeWithTmdbId:tv.id];
    
    if (teebee) {
        return teebee;
    }
    
    teebee = [[Teebee alloc] init];
    
    if (teebee) {
        teebee.name = tv.name;
        teebee.tmdbId = tv.id;
        teebee.posterPath = tv.posterPath;
        teebee.id = -1;
    }
    
    return teebee;
}

- (BOOL)save {
    
    return [[Database sharedDatabase] saveTeebee:self];
    
}

@end
