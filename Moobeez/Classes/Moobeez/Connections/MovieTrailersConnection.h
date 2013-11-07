//
//  MovieTrailersConnection.h
//  Moobeez
//
//  Created by Radu Banea on 11/07/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "TmdbConnection.h"
#import "MovieConnection.h"

@class TmdbMovie;

@interface MovieTrailersConnection : TmdbConnection

- (id)initWithTmdbMovie:(TmdbMovie*)movie completionHandler:(ConnectionMovieHandler)handler;

@end
