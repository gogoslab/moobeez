//
//  TvImagesConnection.m
//  Moobeez
//
//  Created by Radu Banea on 7/04/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "TvImagesConnection.h"
#import "Moobeez.h"

@interface TvImagesConnection ()

@property (strong, nonatomic) TmdbTV* tv;
@property (copy, nonatomic) ConnectionTvHandler customHandler;

@end

@implementation TvImagesConnection

- (id)initWithTmdbTv:(TmdbTV*)tv completionHandler:(ConnectionTvHandler)handler {
    
    self.tv = tv;
    
    self = [super initWithParameters:@{} completionHandler:^(WebserviceResultCode code, NSMutableDictionary *resultDictionary, NSError *error) {
        
        NSLog(@"result: %@", resultDictionary);
        
        [self.tv addEntriesFromTmdbDictionary:@{@"images" : resultDictionary}];

        self.customHandler(code, self.tv);
    }];
    
    self.customHandler = handler;
    
    return self;
}

- (NSString*)defaultUrlSubpath {
    return [UrlTv((long)self.tv.id) stringByAppendingPathComponent:@"images"];
}

@end
