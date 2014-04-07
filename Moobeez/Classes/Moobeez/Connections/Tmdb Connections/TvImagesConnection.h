//
//  TvImagesConnection.h
//  Moobeez
//
//  Created by Radu Banea on 7/04/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "TmdbConnection.h"
#import "TvConnection.h"

@class TmdbTV;

@interface TvImagesConnection : TmdbConnection

- (id)initWithTmdbTv:(TmdbTV*)tv completionHandler:(ConnectionTvHandler)handler;

@end
