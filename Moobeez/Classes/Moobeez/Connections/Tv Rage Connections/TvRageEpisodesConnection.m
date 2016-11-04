//
//  TvRageEpisodesConnection.m
//  Moobeez
//
//  Created by Radu Banea on 11/02/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "TvRageEpisodesConnection.h"
#import "Moobeez.h"

@interface TvRageEpisodesConnection ()

@property (readwrite, nonatomic) NSInteger tvRageId;
@property (copy, nonatomic) ConnectionTvRageEpisodesHandler customHandler;

@end

@implementation TvRageEpisodesConnection

- (id)initWithTvRageId:(NSInteger)tvRageId completionHandler:(ConnectionTvRageEpisodesHandler)handler {
    
    self.tvRageId = tvRageId;
    
    self.customHandler = handler;
    
    if ([Cache cachedTvRageEpisodes][StringInteger((long)self.tvRageId)]) {
        [self performSelector:@selector(cachedResponse) withObject:nil afterDelay:0.01];
        return [self initFakeConnection];
    }
    
    self = [super initWithParameters:[NSDictionary dictionaryWithObject:@(tvRageId) forKey:@"sid"] completionHandler:^(WebserviceResultCode code, DDXMLDocument* xmlDocument, NSError *error) {
        
        //NSLog(@"result: %@", xmlDocument);
        
        if (code == WebserviceResultOk) {

            NSMutableArray* seasons = [[NSMutableArray alloc] init];
            
            DDXMLElement* rootElement = [xmlDocument rootElement];
            
            NSInteger totalSeasons = [[[rootElement elementsForName:@"totalseasons"][0] stringValue] integerValue];
            
            for (int i = 0; i < totalSeasons; ++i) {
                [seasons addObject:[[NSMutableArray alloc] init]];
            }
            
            @try {
                DDXMLElement* episodesListElement = [rootElement elementsForName:@"Episodelist"][0];
                
                NSArray* seasonsElements = [episodesListElement elementsForName:@"Season"];
                
                for (DDXMLElement* seasonElement in seasonsElements) {
                    NSInteger seasonNumber = [[[seasonElement attributeForName:@"no"] stringValue] integerValue];
                    
                    NSMutableArray* season = seasons[seasonNumber - 1];
                    
                    for (DDXMLElement* episodeElement in [seasonElement elementsForName:@"episode"]) {
                        TmdbTvEpisode* episode = [[TmdbTvEpisode alloc] initWithTvRageXmlElement:episodeElement];
                        [season addObject:episode];
                    }
                    
                    [season sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                        return [@(((TmdbTvEpisode*) obj1).episodeNumber) compare:@(((TmdbTvEpisode*) obj2).episodeNumber)];
                    }];
                }
            }
            @catch (NSException *exception) {
                seasons = [[NSMutableArray alloc] init];
            }
            @finally {
            }
            
            [Cache cachedTvRageEpisodes][StringInteger((long)self.tvRageId)] = seasons;
            
            self.customHandler(code, seasons);
        }
        else {
            self.customHandler(code, nil);
        }
    }];
    
    return self;
}

- (NSString*)defaultUrlSubpath {
    return TvRageEpisodesListUrl;
}

- (void)cachedResponse {
    
    [self.activityIndicator stopAnimating];
    self.customHandler(WebserviceResultOk, [Cache cachedTvRageEpisodes][StringInteger((long)self.tvRageId)]);
    
}


@end
