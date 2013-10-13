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

- (id)initWithParameters:(NSDictionary*)parameters completionHandler:(ConnectionCompletionHandler)handler {
    self = [super initWithUrlString:[self.rootUrlPath stringByAppendingString:self.urlSubpath] parameters:parameters completionHandler:^(NSURLResponse *response, id result, NSError *error) {
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

@end
