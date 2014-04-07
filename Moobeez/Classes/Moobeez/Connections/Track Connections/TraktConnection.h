//
//  TraktConnection.h
//  Moobeez
//
//  Created by Radu Banea on 17/02/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "Connection.h"
#import "Constants.h"

@class AppDelegate;

typedef void (^ConnectionCompletionHandler) (WebserviceResultCode code, NSMutableDictionary* resultDictionary, NSError* error);
typedef void (^ConnectionCodeHandler) (WebserviceResultCode code);

@interface TraktConnection : Connection

@property (strong, nonatomic) NSString* urlSubpath;

@property (readonly, nonatomic) NSString* defaultUrlSubpath;

@property (readonly, nonatomic) NSString* rootUrlPath;

@property (readonly, nonatomic) NSString* extraUrl;

@property (readonly, nonatomic) AppDelegate* appDelegate;

- (id)initWithParameters:(NSDictionary*)parameters completionHandler:(ConnectionCompletionHandler)handler;

- (id)startSynchronousConnectionWithParameters:(NSDictionary*)parameters;

- (void)showErrorAlert;

@end
