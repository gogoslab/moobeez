//
//  TVsListConnection.m
//  Moobeez
//
//  Created by Radu Banea on 02/01/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "TVsListConnection.h"
#import "Moobeez.h"

@interface TVsListConnection ()

@property (readwrite, nonatomic) TVsListType tvsType;
@property (copy, nonatomic) ConnectionTVsListHandler customHandler;

@end

@implementation TVsListConnection

- (id)initWithType:(TVsListType)tvsType completionHandler:(ConnectionTVsListHandler)handler {
    
    self.tvsType = tvsType;
    
    self = [super initWithParameters:@{@"page" : @1} completionHandler:^(WebserviceResultCode code, NSMutableDictionary *resultDictionary, NSError *error) {
        
        NSLog(@"result: %@", resultDictionary);
        
        if (code == WebserviceResultOk) {
            
            NSMutableArray* tvs = [[NSMutableArray alloc] init];

            for (NSDictionary* tvDictionary in resultDictionary[@"results"]) {
                TmdbTV* tmdbTv = [[TmdbTV alloc] initWithTmdbDictionary:tvDictionary];
                [tvs addObject:tmdbTv];
            }
        
            self.customHandler(code, tvs);
        }
        else {
            self.customHandler(code, nil);
        }
    }];
    
    self.customHandler = handler;
    
    return self;
}

- (NSString*)defaultUrlSubpath {
    switch (self.tvsType) {
        case TVsOnTheAirType:
            return UrlTvOnTheAir;
            break;
        case TVsPopularType:
            return UrlTvPopular;
            break;
        case TVsTopRatedType:
            return UrlTvTopRated;
            break;
            
        default:
            return @"";
            break;
    }
}

@end
