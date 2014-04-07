//
//  TraktConnection.m
//  Moobeez
//
//  Created by Radu Banea on 17/02/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "TraktConnection.h"
#import "Moobeez.h"

@interface TraktConnection ()

@property (copy, nonatomic) ConnectionCompletionHandler handler;

@property (strong, nonatomic) URLConnection* urlConnection;

@end

@implementation TraktConnection

- (id)initWithParameters:(NSDictionary*)parameters completionHandler:(ConnectionCompletionHandler)handler {
    
    NSString* urlPath = [NSString stringWithFormat:@"%@%@.json/%@%@", self.rootUrlPath, self.urlSubpath, TraktApiKey, self.extraUrl];
    
    self = [super initWithUrlString:urlPath parameters:parameters completionHandler:^(NSURLResponse *response, id result, NSError *error) {
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

- (NSString*)extraUrl {
    return @"";
}

- (AppDelegate*)appDelegate {
    return (AppDelegate*) [UIApplication sharedApplication].delegate;
}

- (void)showErrorAlert {
    [Alert showAlertViewWithTitle:@"Error" message:@"Unable to connect to the server, please try again later" buttonClickedCallback:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
}
@end
