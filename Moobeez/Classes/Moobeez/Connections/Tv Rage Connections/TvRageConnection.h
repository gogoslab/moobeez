//
//  TvRageConnection.h
//  Moobeez
//
//  Created by Radu Banea on 11/02/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "XMLConnection.h"
#import "Constants.h"
#import "DDXMLDocument.h"

@class AppDelegate;

typedef void (^ConnectionXMLCompletionHandler) (WebserviceResultCode code, DDXMLDocument* xmlDocument, NSError* error);
typedef void (^ConnectionCodeHandler) (WebserviceResultCode code);

@interface TvRageConnection : XMLConnection

@property (strong, nonatomic) NSString* urlSubpath;

@property (readonly, nonatomic) NSString* defaultUrlSubpath;

@property (readonly, nonatomic) NSString* rootUrlPath;

@property (readonly, nonatomic) AppDelegate* appDelegate;

- (id)initWithParameters:(NSDictionary*)parameters completionHandler:(ConnectionXMLCompletionHandler)handler;

- (id)startSynchronousConnectionWithParameters:(NSDictionary*)parameters;

- (void)showErrorAlert;

@end
