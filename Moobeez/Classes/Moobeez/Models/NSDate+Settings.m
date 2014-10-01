//
//  NSDate+Settings.m
//  Moobeez
//
//  Created by Radu Banea on 01/10/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "NSDate+Settings.h"
#import "Constants.h"

@implementation NSDate (Settings)

static NSTimeInterval teebeeInterval = -1;

+ (NSTimeInterval)teebeeInterval {
    if (teebeeInterval == -1) {
        NSDictionary* settingsDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:[GROUP_PATH stringByAppendingPathComponent:@"Settings.plist"]];
        teebeeInterval = [settingsDictionary[@"teebeeInterval"] floatValue];
    }
    return teebeeInterval;
}

- (NSDate*)teebeeDate {
    return [NSDate dateWithTimeInterval:[NSDate teebeeInterval] sinceDate:self];
}

- (NSDate*)teebeeDisplayDate {
    return [NSDate dateWithTimeInterval:-[NSDate teebeeInterval] sinceDate:self];
}

@end

