//
//  MovieConnection.h
//  Moobeez
//
//  Created by Radu Banea on 10/23/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "TmdbConnection.h"

@class TmdbMovie;

typedef void (^ConnectionMovieHandler) (WebserviceResultCode code, TmdbMovie* movie);

@interface MovieConnection : TmdbConnection

- (id)initWithTmdbId:(NSInteger)tmdbId completionHandler:(ConnectionMovieHandler)handler;

@end
