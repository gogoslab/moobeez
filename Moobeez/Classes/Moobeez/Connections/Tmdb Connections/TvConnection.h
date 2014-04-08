//
//  TvConnection.h
//  Moobeez
//
//  Created by Radu Banea on 10/23/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "TmdbConnection.h"

@class TmdbTV;

typedef void (^ConnectionTvHandler) (WebserviceResultCode code, TmdbTV* tv);

@interface TvConnection : TmdbConnection

- (id)initWithTmdbId:(NSInteger)tmdbId completionHandler:(ConnectionTvHandler)handler;

@end
