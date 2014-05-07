//
//  Connection.m
//  ConnectionLibrary
//
//  Created by Radu Banea on 10/11/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "ConnectionLibrary.h"
#import "URLParameters.h"

@interface Connection ()

@property (strong, nonatomic) URLConnection* urlConnection;

@property (copy, nonatomic) RawConnectionCompletionHandler rawHandler;

@property (strong, nonatomic) NSURLResponse* response;

@end

@implementation Connection

- (id)initFakeConnection {
    self = [super init];
    
    if (self) {
        self.fakeConnection = YES;
    }
    
    return self;
}

- (id)initWithUrlString:(NSString*)urlString inputJson:(id)inputJson completionHandler:(RawConnectionCompletionHandler)handler {
    
    self = [super init];
    
    if (self) {
        self.urlConnection = [self connectionWithRequest:[self requestWithUrl:urlString andInputJSON:inputJson]];
        self.rawHandler = handler;
    }
    
    return self;
}

- (id)initWithUrlString:(NSString*)urlString parameters:(NSDictionary*)parameters completionHandler:(RawConnectionCompletionHandler)handler {
    
    self = [super init];
    
    if (self) {
        self.urlConnection = [self connectionWithRequest:[self requestWithUrl:urlString andParameters:parameters]];
        self.rawHandler = handler;
    }
    
    return self;
}

- (id)initWithUrlString:(NSString*)urlString completionHandler:(RawConnectionCompletionHandler)handler {
    return [self initWithUrlString:urlString inputJson:nil completionHandler:handler];
}

- (void)startConnection {
    [self.urlConnection start];
    [self.activityIndicator startAnimating];
}

- (void)stopConnection {
    [self.urlConnection cancel];
    
    self.urlConnection.data = nil;
	
    self.urlConnection = nil;
    
    [self.activityIndicator stopAnimating];

}

- (id)startSynchronousConnectionWithUrlString:(NSString*)urlString inputJson:(id)inputJson {
    
    NSURLResponse* response;
    NSError* error;
    
    
    NSData* data = [NSURLConnection sendSynchronousRequest:[self requestWithUrl:urlString andInputJSON:inputJson] returningResponse:&response error:&error];
    
    if (error) {
        NSLog(@"error at sync connection %@ : %@", urlString, error.description);
    }
    
    return [self jsonForData:data];
}

- (id)startSynchronousConnectionWithUrlString:(NSString*)urlString parameters:(NSDictionary*)parameters {
    
    NSURLResponse* response;
    NSError* error;
    
    
    NSData* data = [NSURLConnection sendSynchronousRequest:[self requestWithUrl:urlString andParameters:parameters] returningResponse:&response error:&error];
    
    if (error) {
        NSLog(@"error at sync connection %@ : %@", urlString, error.description);
    }
    
    return [self jsonForData:data];
}

#pragma mark - Connection creation

//use this one for input post parameters for the request

- (NSMutableURLRequest*)requestWithUrl:(NSString*)urlString andInputJSON:(id)inputJSON
{
    // Create a POST request
    
    NSURL* url = [NSURL URLWithString:urlString];
    [url setResourceValue:@(YES) forKey:NSURLIsExcludedFromBackupKey error:nil];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    // Add HTTP header info
    // Note: POST boundaries are described here: http://www.vivtek.com/rfc1867.html
    // and here http://www.w3.org/TR/html4/interact/forms.html
    NSString *POSTBoundary = @"0xKhTmLbOuNdArY";
    [request addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", POSTBoundary] forHTTPHeaderField:@"Content-Type"];
    
    // Add HTTP Body
    NSMutableData *POSTBody = [NSMutableData data];
    [POSTBody appendData:[[NSString stringWithFormat:@"--%@\r\n",POSTBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Add Key/Values to the Body
    NSEnumerator *enumerator = [inputJSON keyEnumerator];
    NSString *key;
    
    while ((key = [enumerator nextObject])) {
        [POSTBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
        [POSTBody appendData:[[NSString stringWithFormat:@"%@", [inputJSON objectForKey:key]] dataUsingEncoding:NSUTF8StringEncoding]];
        [POSTBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", POSTBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // Add the closing -- to the POST Form
    [POSTBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", POSTBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Add the body to the myMedRequest & return
    
    [request setHTTPBody:POSTBody];
    
    return request;
}

/*

 //use this one for json input for the request
 
- (NSMutableURLRequest*)requestWithUrl:(NSString*)urlString andInputJSON:(id)inputJSON
{
    NSURL *url = [NSURL URLWithString:urlString];
	
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
	[request setTimeoutInterval:10];
	[request setHTTPMethod:@"POST"];
    
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSError* jsonError;
    SBJsonWriter* writer = [[SBJsonWriter alloc] init];
    
    NSString* message = [writer stringWithObject:inputJSON error:&jsonError];
    
	if (message)
	{
		[request setHTTPBody:[message dataUsingEncoding:NSUTF8StringEncoding]];
	}
    else {
        if (jsonError) {
            NSLog(@"json write error: %@", jsonError);
        }
    }
    
    return request;
}
*/

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
    
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    return request;
}


- (URLConnection*)connectionWithRequest:(NSURLRequest*)request {
    
	URLConnection* connection = [[URLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
	connection.data = [NSMutableData data];
	
	return connection;
}


#pragma mark - Delegate

- (void)connection:(URLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.response = response;
	[connection.data setLength:0];
}

- (void)connection:(URLConnection *)connection didReceiveData:(NSData *)data
{
	[connection.data appendData:data];
}

#pragma mark - Connection response process

- (void)connection:(URLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"eror connection:%@",error);
	
    self.rawHandler(self.response, connection.data, error);
    
	connection.data = nil;
	self.urlConnection = nil;
    
    [self.activityIndicator stopAnimating];
    
    [self.connectionManager.connections removeObject:self];
}

- (void)connectionDidFinishLoading:(URLConnection *)connection
{
    if (connection.dontProcessResponse) {
        self.rawHandler(self.response, connection.data, nil);
        self.urlConnection = nil;
        [self.connectionManager.connections removeObject:self];
        return;
    }
    
	id jsonResult = [self jsonForData:connection.data];
    
    self.rawHandler(self.response, jsonResult, nil);
    
	connection.data = nil;
	
    self.urlConnection = nil;
    
    [self.activityIndicator stopAnimating];
    
    [self.connectionManager.connections removeObject:self];
}

- (id)jsonForData:(NSData*)data {
    
    NSError *error = NULL;
    
    NSString* responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if (!responseString) {
        responseString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    }
    
	//json that we need to parse
    
    id jsonResult = [NSJSONSerialization
                     JSONObjectWithData:data //1
                     
                     options:kNilOptions
                     error:&error];
    
    NSLog(@"response: %@", responseString);
    
    if (error)
	{
		NSLog(@"error at creating json result: %@",error);
	}

    return jsonResult;
}
@end
