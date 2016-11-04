//
//  MoviesListConnection.m
//  Moobeez
//
//  Created by Radu Banea on 01/22/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "MoviesListConnection.h"
#import "Moobeez.h"

@interface MoviesListConnection ()

@property (readwrite, nonatomic) MoviesListType moviesType;
@property (copy, nonatomic) ConnectionMoviesListHandler customHandler;

@end

@implementation MoviesListConnection

- (id)initWithType:(MoviesListType)moviesType page:(NSInteger)page completionHandler:(ConnectionMoviesListHandler)handler {
    
    self.moviesType = moviesType;
    
    self = [super initWithParameters:@{@"page" : @(page)} completionHandler:^(WebserviceResultCode code, NSMutableDictionary *resultDictionary, NSError *error) {
        
        //NSLog(@"result: %@", resultDictionary);
        
        if (code == WebserviceResultOk) {
            
            NSMutableArray* movies = [[NSMutableArray alloc] init];

            for (NSDictionary* movieDictionary in resultDictionary[@"results"]) {
                TmdbMovie* tmdbMovie = [[TmdbMovie alloc] initWithTmdbDictionary:movieDictionary];
                if (tmdbMovie.posterPath.length) {
                    [movies addObject:tmdbMovie];
                }
            }
        
            self.customHandler(code, movies);
        }
        else {
            self.customHandler(code, nil);
        }
    }];
    
    self.customHandler = handler;
    
    return self;
}

- (NSString*)defaultUrlSubpath {
    switch (self.moviesType) {
        case MoviesNowPlayingType:
            return UrlNowPlaying;
            break;
        case MoviesUpcomingType:
            return UrlUpcoming;
            break;
        case MoviesPopularType:
            return UrlPopular;
            break;
        case MoviesTopRatedType:
            return UrlTopRated;
            break;
            
        default:
            return @"";
            break;
    }
}

@end
