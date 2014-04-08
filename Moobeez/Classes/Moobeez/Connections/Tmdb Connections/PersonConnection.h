//
//  PersonConnection.h
//  Moobeez
//
//  Created by Radu Banea on 11/05/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "TmdbConnection.h"

@class TmdbPerson;

typedef void (^ConnectionPersonHandler) (WebserviceResultCode code, TmdbPerson* person);

@interface PersonConnection : TmdbConnection

- (id)initWithTmdbId:(NSInteger)tmdbId completionHandler:(ConnectionPersonHandler)handler;

@end
