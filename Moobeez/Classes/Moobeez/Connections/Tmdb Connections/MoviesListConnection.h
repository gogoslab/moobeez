//
//  MoviesListConnection.h
//  Moobeez
//
//  Created by Radu Banea on 01/22/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "TmdbConnection.h"

typedef enum MoviesListType {
    MoviesNowPlayingType = 0,
    MoviesUpcomingType,
    MoviesPopularType,
    MoviesTopRatedType,
    } MoviesListType;

typedef void (^ConnectionMoviesListHandler) (WebserviceResultCode code, NSMutableArray* movies);

@interface MoviesListConnection : TmdbConnection

- (id)initWithType:(MoviesListType)moviesType completionHandler:(ConnectionMoviesListHandler)handler;

@end
