//
//  ConfigurationConnection.m
//  Moobeez
//
//  Created by Radu Banea on 10/14/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "ConfigurationConnection.h"
#import "Moobeez.h"

@interface ConfigurationConnection ()

@property (copy, nonatomic) ConnectionCodeHandler customHandler;

@end

@implementation ConfigurationConnection

- (id)initWithCompletionHandler:(ConnectionCodeHandler)handler {
    
    self = [super initWithParameters:nil completionHandler:^(WebserviceResultCode code, NSMutableDictionary *resultDictionary, NSError *error) {
        
        NSLog(@"result: %@", resultDictionary);

        [ImageView setTmdbRootPath:resultDictionary[@"images"][@"secure_base_url"]];
        
        self.customHandler(code);
    }];
    
    self.customHandler = handler;
    
    return self;
}

- (NSString*)defaultUrlSubpath {
    return UrlConfiguration;
}

@end
