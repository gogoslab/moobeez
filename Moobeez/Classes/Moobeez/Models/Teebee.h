//
//  Teebee.h
//  Moobeez
//
//  Created by Radu Banea on 30/01/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "Bee.h"
#import "Constants.h"

typedef enum TeebeeType {
    
    TeebeeNoneType = 0,
    TeebeeToSeeType = 1,
    TeebeeSoonType = 2,
    
    TeebeeAllType,
    
} TeebeeType;

@class TmdbTV;
@class TeebeeEpisode;

@interface Teebee : Bee

@property (readwrite, nonatomic) TeebeeType type;

@property (readwrite, nonatomic) BOOL ended;
@property (strong, nonatomic) NSDate* lastUpdate;

@property (readwrite, nonatomic) NSInteger watchedEpisodesCount;
@property (readwrite, nonatomic) NSInteger notWatchedEpisodesCount;

@property (strong, nonatomic) NSMutableDictionary* seasons;
@property (strong, nonatomic) NSMutableDictionary* episodes;

@property (strong, nonatomic) TeebeeEpisode* nextEpisode;

@property (strong, nonatomic) NSString* tvRageId;
@property (strong, nonatomic) NSMutableArray* tvRageSeasons;


+ (id)teebeeWithTmdbTV:(TmdbTV*)tv;

- (void)addEpisodesCountFromDictionary:(NSDictionary*)dictionary;

- (BOOL)addTeebeeToDatabaseWithCompletion:(EmptyHandler)handler;
- (void)updateEpisodesWithCompletion:(EmptyHandler)completion;

- (void)getTvRageInfo:(CompleteHandler)completion;

@end