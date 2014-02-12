//
//  XMLConnection.h
//  ConnectionLibrary
//
//  Created by Radu Banea on 10/11/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Connection.h"

typedef void (^RawConnectionCompletionHandler) (NSURLResponse* response, id result, NSError* error);

@class ConnectionsManager;

@interface XMLConnection : Connection

@end
