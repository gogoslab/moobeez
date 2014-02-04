//
//  TvSeasonConnection.h
//  Moobeez
//
//  Created by Radu Banea on 10/23/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "TmdbConnection.h"

@class TmdbTvSeason;

typedef void (^ConnectionTvSeasonHandler) (WebserviceResultCode code, TmdbTvSeason* season);

@interface TvSeasonConnection : TmdbConnection

- (id)initWithTmdbId:(NSInteger)tmdbId seasonNumber:(NSInteger)seasonNumber completionHandler:(ConnectionTvSeasonHandler)handler;

@end
