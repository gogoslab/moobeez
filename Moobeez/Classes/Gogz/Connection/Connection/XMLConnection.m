//
//  XMLConnection.m
//  ConnectionLibrary
//
//  Created by Radu Banea on 10/11/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "ConnectionLibrary.h"
#import "DDXML.h"
#import "URLParameters.h"

@interface XMLConnection ()

@property (strong, nonatomic) URLConnection* urlConnection;

@property (copy, nonatomic) RawConnectionCompletionHandler rawHandler;

@property (strong, nonatomic) NSURLResponse* response;

@end

@implementation XMLConnection

- (id)initWithUrlString:(NSString*)urlString completionHandler:(RawConnectionCompletionHandler)handler {
    return [self initWithUrlString:urlString parameters:nil completionHandler:handler];
}

#pragma mark - Connection creation


//use this one for input url parameters for the request

- (NSMutableURLRequest*)requestWithUrl:(NSString*)urlString andParameters:(NSDictionary*)parameters
{
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    if (parameters) {
        urlString = [urlString stringByAppendingString:parameters.parametersString];
    }
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"request url: %@", urlString);
    
	NSURL *url = [NSURL URLWithString:urlString];
    [url setResourceValue:@(YES) forKey:NSURLIsExcludedFromBackupKey error:nil];
	
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
	[request setTimeoutInterval:60];
	[request setHTTPMethod:@"GET"];
    
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    return request;
}

#pragma mark - Connection response process

- (void)connectionDidFinishLoading:(URLConnection *)connection
{
    if (connection.dontProcessResponse) {
        self.rawHandler(self.response, connection.data, nil);
        self.urlConnection = nil;
        [self.connectionManager.connections removeObject:self];
        return;
    }
    
    DDXMLDocument* document = [self documentForData:connection.data];
    
    self.rawHandler(self.response, document, nil);
    
	connection.data = nil;
	
    self.urlConnection = nil;
    
    [self.activityIndicator stopAnimating];
    
    [self.connectionManager.connections removeObject:self];
}

- (DDXMLDocument*)documentForData:(NSData*)data {
    
    NSError *error = NULL;
    
    NSString* responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if (!responseString) {
        responseString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    }
    
	//xml that we need to parse
    
    DDXMLDocument* document = [[DDXMLDocument alloc] initWithXMLString:responseString options:DDXMLDocumentXHTMLKind error:&error];
    
    NSLog(@"response: %@", responseString);
    
    if (error)
	{
		NSLog(@"error at creating json result: %@",error);
	}
    
    return document;
}

@end
