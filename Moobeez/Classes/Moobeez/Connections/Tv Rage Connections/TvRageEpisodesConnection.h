//
//  TvRageEpisodesConnection.h
//  Moobeez
//
//  Created by Radu Banea on 11/02/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "TvRageConnection.h"

@class TmdbTV;

typedef void (^ConnectionTvRageEpisodesHandler) (WebserviceResultCode code, NSMutableArray* seasons);

@interface TvRageEpisodesConnection : TvRageConnection

- (id)initWithTvRageId:(NSInteger)tvRageId completionHandler:(ConnectionTvRageEpisodesHandler)handler;

@end
