//
//  MovieImagesConnection.m
//  Moobeez
//
//  Created by Radu Banea on 11/07/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "MovieImagesConnection.h"
#import "Moobeez.h"

@interface MovieImagesConnection ()

@property (strong, nonatomic) TmdbMovie* movie;
@property (copy, nonatomic) ConnectionMovieHandler customHandler;

@end

@implementation MovieImagesConnection

- (id)initWithTmdbMovie:(TmdbMovie*)movie completionHandler:(ConnectionMovieHandler)handler {
    
    self.movie = movie;
    
    self = [super initWithParameters:@{} completionHandler:^(WebserviceResultCode code, NSMutableDictionary *resultDictionary, NSError *error) {
        
        NSLog(@"result: %@", resultDictionary);
        
        [self.movie addEntriesFromTmdbDictionary:@{@"images" : resultDictionary}];

        self.customHandler(code, self.movie);
    }];
    
    self.customHandler = handler;
    
    return self;
}

- (NSString*)defaultUrlSubpath {
    return [UrlMovie((long)self.movie.id) stringByAppendingPathComponent:@"images"];
}

@end
