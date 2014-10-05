//
//  SearchConnection.m
//  Moobeez
//
//  Created by Radu Banea on 05/09/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "SearchConnection.h"
#import "Moobeez.h"

@interface SearchConnection ()

@property (strong, nonatomic) NSString* query;
@property (readwrite, nonatomic) SearchConnectionType type;
@property (readwrite, nonatomic) NSInteger page;

@property (copy, nonatomic) ConnectionSearchHandler customHandler;

@end

@implementation SearchConnection

- (id)initWithQuery:(NSString*)query type:(SearchConnectionType)type page:(NSInteger)page completionHandler:(ConnectionSearchHandler)handler {
    
    self.query = query;
    self.type = type;
    self.page = page;
    
    self = [super initWithParameters:@{@"query" : query, @"page" : @(self.page)} completionHandler:^(WebserviceResultCode code, NSMutableDictionary *resultDictionary, NSError *error) {
        
        NSLog(@"result: %@", resultDictionary);

        NSMutableArray* results = [[NSMutableArray alloc] init];
        NSInteger numberOfPages = 0;
        
        if ([resultDictionary isKindOfClass:[NSDictionary class]]) {
            for (NSDictionary* dictionary in resultDictionary[@"results"]) {
                if (![dictionary isKindOfClass:[NSDictionary class]]) {
                    continue;
                }
                
                if (type == SearchTypeMovie) {
                    if ([[dictionary stringForKey:@"title"] rangeOfString:self.query options:NSCaseInsensitiveSearch].location == NSNotFound) {
                        continue;
                    }
                }
                else {
                    if ([[dictionary stringForKey:@"name"] rangeOfString:self.query options:NSCaseInsensitiveSearch].location == NSNotFound) {
                        continue;
                    }
                }
                
                switch (type) {
                    case SearchTypeMovie:
                    {
                        TmdbMovie* tmdbMovie = [[TmdbMovie alloc] initWithTmdbDictionary:dictionary];
                        [results addObject:tmdbMovie];
                    }
                        break;
                    case SearchTypeTvShow:
                    {
                        TmdbTV* tmdbTv = [[TmdbTV alloc] initWithTmdbDictionary:dictionary];
                        [results addObject:tmdbTv];
                    }
                        break;
                    case SearchTypePeople:
                    {
                        TmdbPerson* tmdbPerson = [[TmdbPerson alloc] initWithTmdbDictionary:dictionary];
                        [results addObject:tmdbPerson];
                    }
                        break;
                        
                    default:
                        break;
                }
            }
            [results sortUsingSelector:@selector(compareByPopularity:)];
        
            numberOfPages = [resultDictionary[@"total_pages"] integerValue];
        }
        
        self.customHandler(code, results, numberOfPages);
    }];
    
    self.customHandler = handler;
    
    return self;
}

- (NSString*)defaultUrlSubpath {
    
    NSString* path = @"";
    
    switch (self.type) {
        case SearchTypeMovie:
        {
            path = @"movie";
        }
            break;
        case SearchTypeTvShow:
        {
            path = @"tv";
        }
            break;
        case SearchTypePeople:
        {
            path = @"person";
        }
            break;
            
        default:
            break;
    }
    
    return [UrlSearch stringByAppendingPathComponent:path];
}

@end
