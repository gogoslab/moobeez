//
//  SearchTvConnection.h
//  Moobeez
//
//  Created by Radu Banea on 11/01/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "TmdbConnection.h"

@class TmdbTV;

typedef void (^ConnectionSearchTvHandler) (WebserviceResultCode code, NSMutableArray* tvs);

@interface SearchTvConnection : TmdbConnection

- (id)initWithQuery:(NSString*)query completionHandler:(ConnectionSearchTvHandler)handler;

@end
