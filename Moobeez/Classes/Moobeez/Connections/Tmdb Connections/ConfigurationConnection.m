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

        NSDictionary* imagesSettings = resultDictionary[@"images"];
        
        [ImageView setTmdbRootPath:imagesSettings[@"secure_base_url"]];

        [imagesSettings writeToFile:[GROUP_PATH stringByAppendingPathComponent:@"ImagesSettings.plist"] atomically:YES];
        
        self.customHandler(code);
    }];
    
    self.customHandler = handler;
    
    return self;
}

- (NSString*)defaultUrlSubpath {
    return UrlConfiguration;
}

@end
