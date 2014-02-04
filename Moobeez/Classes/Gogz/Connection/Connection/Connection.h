//
//  Connection.h
//  ConnectionLibrary
//
//  Created by Radu Banea on 10/11/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^RawConnectionCompletionHandler) (NSURLResponse* response, id result, NSError* error);

@class ConnectionsManager;

@interface Connection : NSObject

@property (weak, nonatomic) ConnectionsManager* connectionManager;
@property (strong, nonatomic) UIActivityIndicatorView* activityIndicator;

@property (readwrite, nonatomic) BOOL fakeConnection;

- (id)initFakeConnection;
- (id)initWithUrlString:(NSString*)urlString inputJson:(id)inputJson completionHandler:(RawConnectionCompletionHandler)handler;
- (id)initWithUrlString:(NSString*)urlString parameters:(NSDictionary*)parameters completionHandler:(RawConnectionCompletionHandler)handler;
- (id)initWithUrlString:(NSString*)urlString completionHandler:(RawConnectionCompletionHandler)handler;

- (id)startSynchronousConnectionWithUrlString:(NSString*)urlString inputJson:(id)inputJson;
- (id)startSynchronousConnectionWithUrlString:(NSString*)urlString parameters:(NSDictionary*)parameters;

- (void)startConnection;
- (void)stopConnection;

@end
