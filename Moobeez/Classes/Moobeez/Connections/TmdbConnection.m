//
//  ZanaConnection.m
//  Zana
//
//  Created by Radu Banea on 7/17/13.
//  Copyright (c) 2013 Cronos Technologies. All rights reserved.
//

#import "TmdbConnection.h"
#import "Moobeez.h"

@interface TmdbConnection ()

@property (copy, nonatomic) ConnectionCompletionHandler handler;

@property (strong, nonatomic) URLConnection* urlConnection;

@end

@implementation TmdbConnection

- (id)initWithInputJson:(id)inputJson completionHandler:(ConnectionCompletionHandler)handler {
    
    self = [super initWithUrlString:[self.rootUrlPath stringByAppendingString:self.urlSubpath] inputJson:inputJson completionHandler:^(NSURLResponse *response, id result, NSError *error) {
        if (error) {
            self.handler(WebserviceResultError, result, error);
        }
        else  if ([result isKindOfClass:[NSDictionary class]]) {
            self.handler(WebserviceResultOk, result, error);
        }
        else {
            self.handler(WebserviceResultOk, result, error);
        }
    }];
    
    if (self) {
        self.handler = handler;
    }
    
    return self;
}

- (id)startSynchronousConnectionWithInputJson:(id)inputJson {
    
    return [self startSynchronousConnectionWithUrlString:[self.rootUrlPath stringByAppendingString:self.urlSubpath] inputJson:inputJson];

}

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
            NSLog(@"json write error: %@", jsonError.description);
        }
    }
    
    NSLog(@"create request with connection: %@ and input: %@", urlString, inputJSON);
    
    return request;
}

- (NSString*)urlSubpath {
    if (!_urlSubpath) {
        return self.defaultUrlSubpath;
    }
    
    return _urlSubpath;
}

- (NSString*)defaultUrlSubpath {
    return @"";
}

- (NSString*)rootUrlPath {
    return MainTmdbUrl;
}

- (AppDelegate*)appDelegate {
    return (AppDelegate*) [UIApplication sharedApplication].delegate;
}

@end
