//
//  MovieTrailersConnection.m
//  Moobeez
//
//  Created by Radu Banea on 11/07/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "MovieTrailersConnection.h"
#import "Moobeez.h"

@interface MovieTrailersConnection ()

@property (strong, nonatomic) TmdbMovie* movie;
@property (copy, nonatomic) ConnectionMovieHandler customHandler;

@end

@implementation MovieTrailersConnection

- (id)initWithTmdbMovie:(TmdbMovie*)movie completionHandler:(ConnectionMovieHandler)handler {
    
    self.movie = movie;
    
    self = [super initWithParameters:@{} completionHandler:^(WebserviceResultCode code, NSMutableDictionary *resultDictionary, NSError *error) {
        
        NSLog(@"result: %@", resultDictionary);
        
        [self.movie addEntriesFromTmdbDictionary:@{@"trailers" : resultDictionary}];

        self.customHandler(code, self.movie);
    }];
    
    self.customHandler = handler;
    
    return self;
}

- (NSString*)defaultUrlSubpath {
    return [UrlMovie((long)self.movie.id) stringByAppendingPathComponent:@"trailers"];
}

@end
