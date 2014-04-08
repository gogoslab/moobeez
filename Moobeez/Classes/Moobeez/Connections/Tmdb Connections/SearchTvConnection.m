//
//  SearchTvConnection.m
//  Moobeez
//
//  Created by Radu Banea on 11/01/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "SearchTvConnection.h"
#import "Moobeez.h"

@interface SearchTvConnection ()

@property (readwrite, nonatomic) NSString* query;
@property (copy, nonatomic) ConnectionSearchTvHandler customHandler;

@end

@implementation SearchTvConnection

- (id)initWithQuery:(NSString*)query completionHandler:(ConnectionSearchTvHandler)handler {
    
    self.query = query;
    
    self = [super initWithParameters:@{@"query" : query} completionHandler:^(WebserviceResultCode code, NSMutableDictionary *resultDictionary, NSError *error) {
        
        NSLog(@"result: %@", resultDictionary);

        NSMutableArray* tvs = [[NSMutableArray alloc] init];
        
        for (NSDictionary* tvDictionary in resultDictionary[@"results"]) {
            if (![tvDictionary isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            if ([[tvDictionary stringForKey:@"name"] rangeOfString:self.query options:NSCaseInsensitiveSearch].location == NSNotFound) {
                continue;
            }
            
            TmdbTV* tmdbTv = [[TmdbTV alloc] initWithTmdbDictionary:tvDictionary];
            [tvs addObject:tmdbTv];
        }
        
        [tvs sortUsingSelector:@selector(compareByDate:)];
        
        self.customHandler(code, tvs);
    }];
    
    self.customHandler = handler;
    
    return self;
}

- (NSString*)defaultUrlSubpath {
    return UrlSearchTv;
}

@end
