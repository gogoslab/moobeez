//
//  NSDate+Calculator.h
//  Gogz
//
//  Created by Radu Banea on 10/11/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

#define AllComponents NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit

#define EKRecurrenceFrequencyNone -1

@interface NSDate (Calculator)

+ (id)dateWithDay:(int)day month:(int)month andYear:(int)year;

- (BOOL)isEqualWithDate:(NSDate*)date;
- (BOOL)isEqualWithDate:(NSDate*)date forFrequency:(EKRecurrenceFrequency)frequency andInterval:(int)interval;

- (NSDate*)resetToMidnight;
- (NSDate*)resetToLateMidnight;
- (NSDate*)firstDayOfMonth;
- (NSDate*)dateByAddingDays:(NSInteger)days;
- (NSDate*)dateByAddingMonths:(NSInteger)months;
- (NSDate*)dateByAddingYears:(NSInteger)years;

@property (readonly) int weekday;
@property (readonly) int day;
@property (readonly) int month;
@property (readonly) int year;
@property (readonly) int hour;
@property (readonly) int minutes;

@property (readonly) int numberOfDaysInMonth;

@end
