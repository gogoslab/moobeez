//
//  TvSeasonConnection.m
//  Moobeez
//
//  Created by Radu Banea on 10/23/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "TvSeasonConnection.h"
#import "Moobeez.h"

#define StringSeasonId(Id, seasonNumber) [NSString stringWithFormat:@"%ld_%ld", Id, seasonNumber]

@interface TvSeasonConnection ()

@property (readwrite, nonatomic) NSInteger tmdbId;
@property (readwrite, nonatomic) NSInteger seasonNumber;
@property (copy, nonatomic) ConnectionTvSeasonHandler customHandler;

@end

@implementation TvSeasonConnection

- (id)initWithTmdbId:(NSInteger)tmdbId seasonNumber:(NSInteger)seasonNumber completionHandler:(ConnectionTvSeasonHandler)handler {
    
    self.tmdbId = tmdbId;
    self.seasonNumber = seasonNumber;
    
    self.customHandler = handler;
    
    if ([Cache cachedSeasons][StringSeasonId((long)self.tmdbId, self.seasonNumber)]) {
        [self performSelector:@selector(cachedResponse) withObject:nil afterDelay:0.01];
        return [self initFakeConnection];
    }
    
    self = [super initWithParameters:@{} completionHandler:^(WebserviceResultCode code, NSMutableDictionary *resultDictionary, NSError *error) {
        
        NSLog(@"result: %@", resultDictionary);
        
        if (code == WebserviceResultOk) {

            TmdbTvSeason* tmdbTvSeason = [[TmdbTvSeason alloc] initWithTmdbDictionary:resultDictionary];
        
            [Cache cachedSeasons][StringSeasonId((long)self.tmdbId, self.seasonNumber)] = tmdbTvSeason;
            
            self.customHandler(code, tmdbTvSeason);
        }
        else {
            self.customHandler(code, nil);
        }
    }];
    
    return self;
}

- (NSString*)defaultUrlSubpath {
    return UrlTvSeason((long)self.tmdbId, (long)self.seasonNumber);
}

- (void)cachedResponse {
    
    [self.activityIndicator stopAnimating];
    self.customHandler(WebserviceResultOk, [Cache cachedSeasons][StringSeasonId((long)self.tmdbId, self.seasonNumber)]);
    
}


@end
