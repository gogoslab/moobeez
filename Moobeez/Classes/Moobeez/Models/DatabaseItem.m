//
//  DatabaseItem.m
//  Moobeez
//
//  Created by Radu Banea on 10/14/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "DatabaseItem.h"

@interface DatabaseItem ()

@property (readwrite, nonatomic) NSInteger id;

@end

@implementation DatabaseItem

+ (id)initWithId:(NSInteger)id {
    return [[DatabaseItem alloc] init];
}

- (id)initWithDatabaseDictionary:(NSDictionary*)databaseDictionary {
    
    self = [self init];
    
    if (self) {
        
        self.id = [databaseDictionary[@"ID"] integerValue];
        
    }
    
    return self;
}
@end
