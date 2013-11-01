//
//  SearchMovieConnection.h
//  Moobeez
//
//  Created by Radu Banea on 11/01/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "TmdbConnection.h"

@class TmdbMovie;

typedef void (^ConnectionSearchMovieHandler) (WebserviceResultCode code, NSMutableArray* movies);

@interface SearchMovieConnection : TmdbConnection

- (id)initWithQuery:(NSString*)query completionHandler:(ConnectionSearchMovieHandler)handler;

@end
