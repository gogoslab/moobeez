//
//  TmdbConnection.h
//  Moobeez
//
//  Created by Radu Banea on 10/11/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "Connection.h"
#import "Constants.h"

@class AppDelegate;

typedef void (^ConnectionCompletionHandler) (WebserviceResultCode code, NSMutableDictionary* resultDictionary, NSError* error);
typedef void (^ConnectionCodeHandler) (WebserviceResultCode code);

@interface TmdbConnection : Connection

@property (strong, nonatomic) NSString* urlSubpath;

@property (readonly, nonatomic) NSString* defaultUrlSubpath;

@property (readonly, nonatomic) NSString* rootUrlPath;

@property (readonly, nonatomic) AppDelegate* appDelegate;

- (id)initWithParameters:(NSDictionary*)parameters completionHandler:(ConnectionCompletionHandler)handler;

- (id)startSynchronousConnectionWithParameters:(NSDictionary*)parameters;

- (void)showErrorAlert;

@end
