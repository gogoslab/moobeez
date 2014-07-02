//
//  NSDate+Calculator.h
//  Gogz
//
//  Created by Radu Banea on 10/11/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

#define AllComponents NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekOfYear | NSCalendarUnitWeekday

#define EKRecurrenceFrequencyNone -1

@interface NSDate (Calculator)

+ (id)dateWithDay:(int)day month:(int)month andYear:(int)year;

- (BOOL)isEqualWithDate:(NSDate*)date;
- (BOOL)isEqualWithDate:(NSDate*)date forFrequency:(EKRecurrenceFrequency)frequency andInterval:(NSInteger)interval;

- (NSDate*)resetToMidnight;
- (NSDate*)resetToLateMidnight;
- (NSDate*)firstDayOfMonth;
- (NSDate*)dateByAddingDays:(NSInteger)days;
- (NSDate*)dateByAddingMonths:(NSInteger)months;
- (NSDate*)dateByAddingYears:(NSInteger)years;

@property (readonly) NSInteger weekday;
@property (readonly) NSInteger day;
@property (readonly) NSInteger month;
@property (readonly) NSInteger year;
@property (readonly) NSInteger hour;
@property (readonly) NSInteger minutes;

@property (readonly) NSInteger numberOfDaysInMonth;

@end
