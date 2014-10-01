//
//  Settings.h
//  Moobeez
//
//  Created by Radu Banea on 10/30/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>
#import "NSDate+Settings.h"

enum CacheDurationType {
    CacheDurationTypeOneHour = 0,
    CacheDurationTypeOneDay,
    CacheDurationTypeOneWeek,
    CacheDurationTypeOneMonth,
    CacheDurationTypeForever,
    CacheDurationTypesCount
};

@interface Settings : NSObject

@property (readwrite, nonatomic) BOOL facebookOn;

@property (strong, nonatomic) NSDictionary* facebookProfile;
@property (strong, nonatomic) NSDictionary* tmdbConfiguration;

@property (readwrite, nonatomic) BOOL backupOnICloud;
@property (readwrite, nonatomic) BOOL cacheImages;
@property (readwrite, nonatomic) NSInteger cacheDuration;
@property (readonly, nonatomic) NSString* cacheDurationString;

@property (readonly, nonatomic) NSArray* cacheDurationsStrings;

@property (readwrite, nonatomic) NSInteger updateShowsInterval;

@property (readwrite, nonatomic) NSTimeInterval teebeeInterval;

@property (readonly, nonatomic) NSDate* teebeezToday;

+ (Settings*)sharedSettings;

- (BOOL)loadSettings;
- (void)saveSettings;

- (void)deleteOldImages;

@end

@interface NSObject (Settings)

@property (readonly, nonatomic) Settings* sharedSettings;

@end

