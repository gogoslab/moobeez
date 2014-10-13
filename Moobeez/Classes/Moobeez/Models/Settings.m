//
//  Settings.m
//  Moobeez
//
//  Created by Radu Banea on 01/30/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "Settings.h"
#import "Moobeez.h"

@implementation Settings

static Settings* _sharedSettings;

+ (Settings*)sharedSettings {
    
    if (!_sharedSettings) {
        _sharedSettings = [[Settings alloc] init];
    }
    return _sharedSettings;
}

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (BOOL)loadSettings {
    NSDictionary* settingsDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:[GROUP_PATH stringByAppendingPathComponent:@"Settings.plist"]];
    
    if (!settingsDictionary) {
        
        self.facebookOn = NO;
        self.backupOnICloud = YES;
        self.cacheImages = YES;
        self.cacheDuration = CacheDurationTypeOneDay;
        self.updateShowsInterval = 1;
//        self.teebeeInterval = 0;
        self.teebeeInterval = - 24 * 3600;
        
        [self saveSettings];
        
        return NO;
    }
    
    self.facebookOn = [settingsDictionary boolForKey:@"facebookOn"];
    self.backupOnICloud = [settingsDictionary boolForKey:@"backupOnICloud"];
    self.cacheImages = [settingsDictionary boolForKey:@"cacheImages"];
    self.cacheDuration = [settingsDictionary integerForKey:@"cacheDuration"];
    
    self.updateShowsInterval = [settingsDictionary integerForKey:@"updateShowsInterval"];
    if (self.updateShowsInterval == 0) {
        self.updateShowsInterval = 1;
    }

    self.teebeeInterval = 0;//[settingsDictionary floatForKey:@"teebeeInterval"];
    self.teebeeInterval = - 24 * 3600;

    return YES;
}

- (void)saveSettings {
    
    NSMutableDictionary* settingsDictionary = [[NSMutableDictionary alloc] init];
    
    [settingsDictionary setBool:self.facebookOn forKey:@"facebookOn"];
    [settingsDictionary setBool:self.backupOnICloud forKey:@"backupOnICloud"];
    [settingsDictionary setBool:self.cacheImages forKey:@"cacheImages"];
    [settingsDictionary setInteger:self.cacheDuration forKey:@"cacheDuration"];
    
    [settingsDictionary setInteger:self.updateShowsInterval forKey:@"updateShowsInterval"];
    
    [settingsDictionary setFloat:self.teebeeInterval forKey:@"teebeeInterval"];

    [settingsDictionary writeToFile:[GROUP_PATH stringByAppendingPathComponent:@"Settings.plist"] atomically:YES];
}

- (NSString*)cacheDurationString {
    return self.cacheDurationsStrings[self.cacheDuration];
}

- (NSArray*)cacheDurationsStrings {
    return @[@"1 hour", @"1 day", @"1 week", @"1 month", @"forever"];
}

- (void)deleteOldImages {
    
    NSTimeInterval duration = 0;
    
    if (!self.cacheImages) {
        duration = 0;
    }
    else {
        switch (self.cacheDuration) {
            case CacheDurationTypeOneHour:
                duration = 3600;
                break;
            case CacheDurationTypeOneDay:
                duration = 3600 * 24;
                break;
            case CacheDurationTypeOneWeek:
                duration = 3600 * 24 * 7;
                break;
            case CacheDurationTypeOneMonth:
                duration = 3600 * 24 * 30;
                break;
            default:
                return;
                break;
        }
    }

    NSArray* subpaths = [[NSFileManager defaultManager] subpathsAtPath:offlineRootPath];
    
    NSMutableArray* oldImageFilePaths = [[NSMutableArray alloc] init];

    for (NSString* subpath in subpaths) {
        
        NSString* absolutePath = [offlineRootPath stringByAppendingPathComponent:subpath];
//        NSLog(@"last access: %@", [[NSFileManager defaultManager] fileAtPathLastAccessedDate:absolutePath]);
        if ([[[NSFileManager defaultManager] fileAtPathLastAccessedDate:absolutePath] timeIntervalSinceNow] < - duration) {
            [oldImageFilePaths addObject:absolutePath];
        }
    }
    
    for (NSString* path in oldImageFilePaths) {
        if([[NSFileManager defaultManager] removeItemAtPath:path error:nil]) {
            NSLog(@"delete file: %@", path);
        }
    }
    
}

- (NSDate*)teebeezToday {
    return [[NSDate date] teebeeDate];
}

@end

@implementation NSObject (Settings)

- (Settings*)sharedSettings {
    return [Settings sharedSettings];
}

@end

