//
//  ConfigurationConnection.h
//  Moobeez
//
//  Created by Radu Banea on 10/14/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "TmdbConnection.h"

@interface ConfigurationConnection : TmdbConnection

- (id)initWithCompletionHandler:(ConnectionCodeHandler)handler;

@end
