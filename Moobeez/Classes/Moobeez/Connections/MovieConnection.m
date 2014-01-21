//
//  MovieConnection.m
//  Moobeez
//
//  Created by Radu Banea on 10/23/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "MovieConnection.h"
#import "Moobeez.h"

@interface MovieConnection ()

@property (readwrite, nonatomic) NSInteger tmdbId;
@property (copy, nonatomic) ConnectionMovieHandler customHandler;

@end

@implementation MovieConnection

- (id)initWithTmdbId:(NSInteger)tmdbId completionHandler:(ConnectionMovieHandler)handler {
    
    self.tmdbId = tmdbId;
    
    self = [super initWithParameters:[NSDictionary dictionaryWithObject:@"casts" forKey:@"append_to_response"] completionHandler:^(WebserviceResultCode code, NSMutableDictionary *resultDictionary, NSError *error) {
        
        NSLog(@"result: %@", resultDictionary);
        
        if (code == WebserviceResultOk) {

            TmdbMovie* tmdbMovie = [[TmdbMovie alloc] initWithTmdbDictionary:resultDictionary];
        
            self.customHandler(code, tmdbMovie);
        }
        else {
            self.customHandler(code, nil);
        }
    }];
    
    self.customHandler = handler;
    
    return self;
}

- (NSString*)defaultUrlSubpath {
    return UrlMovie((long)self.tmdbId);
}

@end
