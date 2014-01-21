//
//  ZanaConnection.h
//  Zana
//
//  Created by Radu Banea on 7/17/13.
//  Copyright (c) 2013 Cronos Technologies. All rights reserved.
//

#import "Connection.h"
#import "Constants.h"

typedef enum WebserviceResultCode {
    WebserviceResultError = 0,
    WebserviceResultOk = 1
} WebserviceResultCode;

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
