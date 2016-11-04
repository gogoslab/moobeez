//
//  SearchMovieConnection.m
//  Moobeez
//
//  Created by Radu Banea on 11/01/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "SearchMovieConnection.h"
#import "Moobeez.h"

@interface SearchMovieConnection ()

@property (readwrite, nonatomic) NSString* query;
@property (copy, nonatomic) ConnectionSearchMovieHandler customHandler;

@end

@implementation SearchMovieConnection

- (id)initWithQuery:(NSString*)query completionHandler:(ConnectionSearchMovieHandler)handler {
    
    self.query = query;
    
    self = [super initWithParameters:@{@"query" : query} completionHandler:^(WebserviceResultCode code, NSMutableDictionary *resultDictionary, NSError *error) {
        
        //NSLog(@"result: %@", resultDictionary);

        NSMutableArray* movies = [[NSMutableArray alloc] init];
        
        for (NSDictionary* movieDictionary in resultDictionary[@"results"]) {
            if (![movieDictionary isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            if ([[movieDictionary stringForKey:@"title"] rangeOfString:self.query options:NSCaseInsensitiveSearch].location == NSNotFound) {
                continue;
            }
            
            TmdbMovie* tmdbMovie = [[TmdbMovie alloc] initWithTmdbDictionary:movieDictionary];
            [movies addObject:tmdbMovie];
        }
        
        [movies sortUsingSelector:@selector(compareByDate:)];
        
        self.customHandler(code, movies);
    }];
    
    self.customHandler = handler;
    
    return self;
}

- (NSString*)defaultUrlSubpath {
    return UrlSearchMovie;
}

@end
