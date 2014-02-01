//
//  TVsListConnection.h
//  Moobeez
//
//  Created by Radu Banea on 02/01/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "TmdbConnection.h"

typedef enum TVsListType {
    TVsOnTheAirType = 0,
    TVsPopularType,
    TVsTopRatedType,
    } TVsListType;

typedef void (^ConnectionTVsListHandler) (WebserviceResultCode code, NSMutableArray* tvs);

@interface TVsListConnection : TmdbConnection

- (id)initWithType:(TVsListType)tvsType completionHandler:(ConnectionTVsListHandler)handler;

@end
