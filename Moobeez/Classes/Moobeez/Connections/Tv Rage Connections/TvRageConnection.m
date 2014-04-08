//
//  TvRageConnection.m
//  Moobeez
//
//  Created by Radu Banea on 11/02/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "TvRageConnection.h"
#import "Moobeez.h"

@interface TvRageConnection ()

@property (copy, nonatomic) ConnectionXMLCompletionHandler handler;

@property (strong, nonatomic) URLConnection* urlConnection;

@end

@implementation TvRageConnection

- (id)initWithParameters:(NSDictionary*)parameters completionHandler:(ConnectionXMLCompletionHandler)handler {
    
    NSMutableDictionary* tvRageParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];

    self = [super initWithUrlString:[self.rootUrlPath stringByAppendingString:self.urlSubpath] parameters:tvRageParameters completionHandler:^(NSURLResponse *response, id result, NSError *error) {
        if (error) {
            self.handler(WebserviceResultError, result, error);
            [self showErrorAlert];
        }
        else  if ([result isKindOfClass:[DDXMLDocument class]]) {
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
    return TvRageMainUrl;
}

- (AppDelegate*)appDelegate {
    return (AppDelegate*) [UIApplication sharedApplication].delegate;
}

- (void)showErrorAlert {
    [Alert showAlertViewWithTitle:@"Error" message:@"Unable to connect to the server, please try again later" buttonClickedCallback:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
}
@end
