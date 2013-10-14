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

- (id)initWithDictionary:(NSDictionary *)dictionary {
    
    self = [self init];
    
    if (self) {
        
        self.id = [dictionary[@"ID"] integerValue];
        
    }
    
    return self;
}
@end
