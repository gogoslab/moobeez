//
//  TvConnection.m
//  Moobeez
//
//  Created by Radu Banea on 10/23/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "TvConnection.h"
#import "Moobeez.h"

@interface TvConnection ()

@property (readwrite, nonatomic) NSInteger tmdbId;
@property (copy, nonatomic) ConnectionTvHandler customHandler;

@end

@implementation TvConnection

- (id)initWithTmdbId:(NSInteger)tmdbId completionHandler:(ConnectionTvHandler)handler {
    
    self.tmdbId = tmdbId;
    
    self.customHandler = handler;
    
    if ([Cache cachedTVs][StringInteger((long)self.tmdbId)]) {
        [self performSelector:@selector(cachedResponse) withObject:nil afterDelay:0.01];
        return [self initFakeConnection];
    }
    
    self = [super initWithParameters:[NSDictionary dictionaryWithObject:@"credits,external_ids" forKey:@"append_to_response"] completionHandler:^(WebserviceResultCode code, NSMutableDictionary *resultDictionary, NSError *error) {
        
        NSLog(@"result: %@", resultDictionary);
        
        if (code == WebserviceResultOk) {

            TmdbTV* tmdbTv = [[TmdbTV alloc] initWithTmdbDictionary:resultDictionary];
        
            [Cache cachedTVs][StringInteger((long)tmdbId)] = tmdbTv;
            
            self.customHandler(code, tmdbTv);
        }
        else {
            self.customHandler(code, nil);
        }
    }];
    
    return self;
}

- (NSString*)defaultUrlSubpath {
    return UrlTv((long)self.tmdbId);
}

- (void)cachedResponse {
    
    [self.activityIndicator stopAnimating];
    self.customHandler(WebserviceResultOk, [Cache cachedTVs][StringInteger((long)self.tmdbId)]);
    
}


@end
