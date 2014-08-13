//
//  Teebee.m
//  Moobeez
//
//  Created by Radu Banea on 30/01/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "Teebee.h"
#import "Moobeez.h"

@interface Teebee ()

@property (strong, nonatomic) NSMutableArray* seasonsToUpdate;
@property (copy, nonatomic) EmptyHandler updateEpisodesHandler;

@end

@implementation Teebee

+ (id)initWithId:(NSInteger)id {
    return [[Database sharedDatabase] teebeeWithId:id];
}

- (id)initWithDatabaseDictionary:(NSDictionary*)databaseDictionary {
    
    self = [super initWithDatabaseDictionary:databaseDictionary];
    
    if (self) {
        self.type = [databaseDictionary[@"type"] intValue];
        self.seasonsToUpdate = [[NSMutableArray alloc] init];
        
        self.ended = [databaseDictionary[@"ended"] boolValue];
        
        if (databaseDictionary[@"lastUpdate"]) {
            self.lastUpdate = [NSDate dateWithTimeIntervalSince1970:[databaseDictionary[@"lastUpdate"] doubleValue]];
        }
        
        self.notWatchedEpisodesCount = -1;
        self.watchedEpisodesCount = 0;
        
        [self addEpisodesCountFromDictionary:databaseDictionary];
        
        if (databaseDictionary[@"airDate"]) {
            self.nextEpisode = [[TeebeeEpisode alloc] initWithDatabaseDictionary:databaseDictionary];
        }
        
        if (databaseDictionary[@"tvRageId"] && [databaseDictionary[@"tvRageId"] isKindOfClass:[NSString class]]) {
            self.tvRageId = databaseDictionary[@"tvRageId"];
        }

    }
    
    return self;
}

- (void)addEpisodesCountFromDictionary:(NSDictionary*)dictionary {

    if (dictionary[@"watchedEpisodesCount"]) {
        self.watchedEpisodesCount = [dictionary[@"watchedEpisodesCount"] integerValue];
    }
    
    if (dictionary[@"notWatchedEpisodesCount"]) {
        self.notWatchedEpisodesCount = [dictionary[@"notWatchedEpisodesCount"] integerValue];
    }
}

- (NSMutableDictionary*)databaseDictionary {
    
    NSMutableDictionary* databaseDictionary = super.databaseDictionary;
    
    databaseDictionary[@"ended"] = [NSString stringWithFormat:@"%d", self.ended];
    
    if (self.lastUpdate) {
        databaseDictionary[@"lastUpdate"] = [NSString stringWithFormat:@"%.0f", [self.lastUpdate timeIntervalSince1970]];
    }
    
//    if (self.tvRageId && [self.tvRageId isKindOfClass:[NSString class]]) {
//        databaseDictionary[@"tvRageId"] = self.tvRageId;
//    }
    
    return databaseDictionary;
}

+ (id)teebeeWithTmdbTV:(TmdbTV*)tv {
    Teebee* teebee = [[Database sharedDatabase] teebeeWithTmdbId:tv.id];
    
    if (teebee) {
        return teebee;
    }
    
    teebee = [[Teebee alloc] init];
    
    if (teebee) {
        teebee.name = tv.name;
        teebee.tmdbId = tv.id;
        if ([tv.tvRageId isKindOfClass:[NSString class]]) {
            teebee.tvRageId = tv.tvRageId;
        }
        teebee.posterPath = tv.posterPath;
        teebee.backdropPath = tv.backdropPath;
        teebee.id = -1;
        teebee.watchedEpisodesCount = 0;
        teebee.rating = -1;
        teebee.comments = @"";
        teebee.ended = [tv.status isEqualToString:@"Ended"];
        
        teebee.seasonsToUpdate = [[NSMutableArray alloc] init];

    }
    
    return teebee;
}

- (BOOL)addTeebeeToDatabaseWithCompletion:(EmptyHandler)handler {
    
    UIView* teebeeLoadingView = [[NSBundle mainBundle] loadNibNamed:@"TeebeeLoadingView" owner:self options:nil][0];
    
    [LoadingView showLoadingViewWithContent:teebeeLoadingView];
    
    if([self save]) {
        [self updateEpisodesWithCompletion:^{
            [LoadingView hideLoadingView];
            handler();
        }];
        return YES;
    }
    else {
        [LoadingView hideLoadingView];
        return NO;
    }
}

- (BOOL)save {
    
    return [[Database sharedDatabase] saveTeebee:self];
    
}

- (void)updateEpisodesWithCompletion:(EmptyHandler)completion {
    
    self.updateEpisodesHandler = completion;
    
    if (!self.episodes) {
        self.episodes = [[NSMutableDictionary alloc] init];
    }
    
    TvConnection* connection = [[TvConnection alloc] initWithTmdbId:self.tmdbId completionHandler:^(WebserviceResultCode code, TmdbTV *tv) {
        
        if (code == WebserviceResultOk) {

            if (self.seasonsToUpdate.count == 0) {
                [self performSelector:@selector(updateNextSeason) withObject:nil afterDelay:0.01];
            }

            NSInteger seasonNumber = [[Database sharedDatabase] lastSeasonOfTeebee:self];
            
            for (TmdbTvSeason* season in tv.seasons) {
                if (season.seasonNumber >=  seasonNumber) {
                    [self.seasonsToUpdate addObject:season];
                }
            }
            
            self.ended = !tv.inProduction;
        }
    }];
    
    [[ConnectionsManager sharedManager] startConnection:connection];
}

- (void)updateNextSeason {
    
    if (self.seasonsToUpdate.count == 0) {
        [self updateEpisodesInDatabase];
        return;
    }
    
    TmdbTvSeason* season = self.seasonsToUpdate[0];
    
    while (season.seasonNumber == 0) {
        [self.seasonsToUpdate removeObjectAtIndex:0];
        [self performSelector:@selector(updateNextSeason) withObject:nil afterDelay:0.01];
        return;
    }
    
    NSMutableDictionary* seasonDictionary = self.episodes[StringInteger((long)season.seasonNumber)];
    
    if (!seasonDictionary) {
        seasonDictionary = [[NSMutableDictionary alloc] init];
        self.episodes[StringInteger((long)season.seasonNumber)] = seasonDictionary;
    }
    
    TvSeasonConnection* connection = [[TvSeasonConnection alloc] initWithTmdbId:self.tmdbId seasonNumber:season.seasonNumber completionHandler:^(WebserviceResultCode code, TmdbTvSeason *season) {
        
        if (code == WebserviceResultOk) {
            
            [[Database sharedDatabase] pullEpisodesForTeebee:self inSeason:season.seasonNumber];
            
            for (TmdbTvEpisode* episode in season.episodes) {
                
                TeebeeEpisode* teebeeEpisode = seasonDictionary[StringInteger((long)episode.episodeNumber)];
                
                if (!teebeeEpisode) {
                    teebeeEpisode = [[TeebeeEpisode alloc] init];
                    
                    seasonDictionary[StringInteger((long)episode.episodeNumber)] = teebeeEpisode;
                    
                    teebeeEpisode.seasonNumber = season.seasonNumber;
                    teebeeEpisode.episodeNumber = episode.episodeNumber;
                    
                    teebeeEpisode.watched = NO;
                    
                    teebeeEpisode.airDate = episode.date;
                    
                    teebeeEpisode.updated = YES;
                }
                else {
                    if (![teebeeEpisode.airDate isEqualToDate:episode.date]) {
                        teebeeEpisode.airDate = episode.date;
                        teebeeEpisode.updated = YES;
                    }
                }
            }
            
            [self.seasonsToUpdate removeObjectAtIndex:0];
            
            [self updateNextSeason];
        }
    }];
    
    [[ConnectionsManager sharedManager] startConnection:connection];
    
}

- (void)updateEpisodesInDatabase {
    
    NSMutableArray* insertEpisodesDictionaries = [[NSMutableArray alloc] init];
    NSMutableArray* insertEpisodes = [[NSMutableArray alloc] init];
    NSMutableArray* updatedEpisodesDates = [[NSMutableArray alloc] init];
    NSMutableArray* updatedEpisodesIds = [[NSMutableArray alloc] init];
    NSMutableArray* updatedEpisodes = [[NSMutableArray alloc] init];
    
    for (NSMutableDictionary* season in self.episodes.allValues) {
        
        for (TeebeeEpisode* episode in season.allValues) {
            
            if (episode.id == -1) {
                
                NSMutableDictionary* episodeDictionary = episode.databaseDictionary;
                
                episodeDictionary[@"teebeeId"] = StringInteger((long)self.id);
                
                [insertEpisodesDictionaries addObject:episodeDictionary];
                [insertEpisodes addObject:episode];
            }
            else if (episode.updated) {
                
                if (episode.airDate) {
                    [updatedEpisodesDates addObject:episode.databaseDictionary[@"airDate"]];
                    [updatedEpisodesIds addObject:StringInteger((long)episode.id)];
                    [updatedEpisodes addObject:episode];
                }
            }
        }
    }
    
    if (insertEpisodes.count) {
        
        NSMutableArray* ids = [[Database sharedDatabase] insertObjects:insertEpisodesDictionaries atKeys:@[@"teebeeId", @"seasonNumber", @"episodeNumber", @"watched", @"airDate"] intoTable:@"Episodes"];
        
        if (ids) {
            for (int i = 0; i < MIN(insertEpisodes.count, ids.count); ++i) {
                ((TeebeeEpisode*) insertEpisodes[i]).id = [ids[i] integerValue];
            }
        }
    }
    
    if (updatedEpisodes.count) {
        
        if([[Database sharedDatabase] updateColumnValues:updatedEpisodesDates forColumn:@"airDate" intoTable:@"Episodes" forIds:updatedEpisodesIds]) {
            
            for (TeebeeEpisode* episode in updatedEpisodes) {
                episode.updated = NO;
            }
        }
    }
    
    self.lastUpdate = [NSDate date];
    
    [self save];
    
    if (self.updateEpisodesHandler) {
        self.updateEpisodesHandler();
    }
}

- (void)getTvRageInfo:(CompleteHandler)completion {
    
    if (!self.tvRageId) {
        
    }
    else {
        [self getTvRageEpisodes:completion];
    }
}

- (void)getTvRageEpisodes:(CompleteHandler)completion {
    
    TvRageEpisodesConnection* connection = [[TvRageEpisodesConnection alloc] initWithTvRageId:[self.tvRageId integerValue] completionHandler:^(WebserviceResultCode code, NSMutableArray *seasons) {
        if (code == WebserviceResultOk) {
            self.tvRageSeasons = seasons;
            completion(YES);
        }
        else {
            completion(NO);
        }
    }];
    
    [[ConnectionsManager sharedManager] startConnection:connection];
}

@end
