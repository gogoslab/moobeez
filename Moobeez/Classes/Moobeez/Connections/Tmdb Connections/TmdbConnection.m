//
//  TmdbConnection.m
//  Moobeez
//
//  Created by Radu Banea on 10/11/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "TmdbConnection.h"
#import "Moobeez.h"

@interface TmdbConnection ()

@property (copy, nonatomic) ConnectionCompletionHandler handler;

@property (strong, nonatomic) URLConnection* urlConnection;

@end

@implementation TmdbConnection

- (id)initWithParameters:(NSDictionary*)parameters completionHandler:(ConnectionCompletionHandler)handler {
    
    NSMutableDictionary* tmdbParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
    [tmdbParameters setObject:TmdbApiKey forKey:@"api_key"];

    self = [super initWithUrlString:[self.rootUrlPath stringByAppendingString:self.urlSubpath] parameters:tmdbParameters completionHandler:^(NSURLResponse *response, id result, NSError *error) {
        if (error) {
            self.handler(WebserviceResultError, result, error);
            [self showErrorAlert];
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

- (id)startSynchronousConnectionWithParameters:(NSDictionary*)parameters {
    
    return [self startSynchronousConnectionWithUrlString:[self.rootUrlPath stringByAppendingString:self.urlSubpath] parameters:parameters];

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

- (void)showErrorAlert {
    [Alert showAlertViewWithTitle:@"Error" message:@"Unable to connect to the server, please try again later" buttonClickedCallback:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
}
@end
