//
//  NSDate+Calculator.m
//  Gogz
//
//  Created by Radu Banea on 10/11/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "NSDate+Calculator.h"


@implementation NSDate (Calculator)

+ (id)dateWithDay:(int)day month:(int)month andYear:(int)year {
    __autoreleasing NSDateComponents* dateComponents = [[NSDateComponents alloc] init];
    
    [dateComponents setDay:day];
    [dateComponents setMonth:month];
    [dateComponents setYear:year];
    
    return [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
}

- (NSDate*)resetToMidnight {
    
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    NSDateComponents* dateComponents = [calendar components:AllComponents fromDate:self];
    
    [dateComponents setHour:0];
    [dateComponents setMinute:0];
    [dateComponents setSecond:0];
    
    return [calendar dateFromComponents:dateComponents];
}

- (NSDate*)resetToLateMidnight {
    
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    NSDateComponents* dateComponents = [calendar components:AllComponents fromDate:self];
    
    [dateComponents setHour:23];
    [dateComponents setMinute:59];
    [dateComponents setSecond:59];
    
    return [calendar dateFromComponents:dateComponents];
}

- (BOOL)isEqualWithDate:(NSDate*)date {
    NSDate* firstDate = [self resetToMidnight];
    NSDate* secondDate = [date resetToMidnight];
    
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    NSDateComponents* firstDateComponents = [calendar components:AllComponents fromDate:firstDate];
    NSDateComponents* secondDateComponents = [calendar components:AllComponents fromDate:secondDate];
    
    BOOL sameDay = ([firstDateComponents day] == [secondDateComponents day]);
    BOOL sameMonth = ([firstDateComponents month] == [secondDateComponents month]);
    BOOL sameYear = ([firstDateComponents year] == [secondDateComponents year]);
    
    return (sameDay && sameMonth && sameYear);
}

- (BOOL)isEqualWithDate:(NSDate*)date forFrequency:(EKRecurrenceFrequency)frequency andInterval:(NSInteger)interval {

    NSDate* firstDate = [self resetToMidnight];
    NSDate* secondDate = [date resetToMidnight];

    if ([firstDate timeIntervalSinceDate:secondDate] > 0) {
        return NO;
    }
    
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    NSDateComponents* firstDateComponents = [calendar components:AllComponents fromDate:firstDate];
    NSDateComponents* secondDateComponents = [calendar components:AllComponents fromDate:secondDate];

    BOOL sameDay = ([firstDateComponents day] == [secondDateComponents day]);
    BOOL sameWeekDay = ([firstDateComponents weekday] == [secondDateComponents weekday]);
    BOOL sameMonth = ([firstDateComponents month] == [secondDateComponents month]);
    
    NSInteger numberOfDaysInMonth = secondDate.numberOfDaysInMonth;
    
    //check if the day of the first date can exist in the second date
    if ([firstDateComponents day] >= numberOfDaysInMonth
        && ([secondDateComponents day] + 1) == numberOfDaysInMonth) {
        sameDay = YES;
    }
    
    switch (frequency) {

        case EKRecurrenceFrequencyDaily:
        {
            NSDateComponents* dateComponents = [calendar components:AllComponents fromDate:firstDate toDate:secondDate options:0];

            return (labs([dateComponents day]) % interval == 0);
        }
            break;

        case EKRecurrenceFrequencyWeekly:
        {
            NSDateComponents* dateComponents = [calendar components:AllComponents fromDate:firstDate toDate:secondDate options:0];
            return (sameWeekDay && (labs([dateComponents weekOfYear]) % interval == 0));
        }
            break;

        case EKRecurrenceFrequencyMonthly: {
            NSDateComponents* dateComponents = [calendar components:AllComponents fromDate:firstDate toDate:secondDate options:0];

            return (sameDay && (labs([dateComponents month]) % interval == 0));
        }
            break;

        case EKRecurrenceFrequencyYearly: {
            NSDateComponents* dateComponents = [calendar components:AllComponents fromDate:firstDate toDate:secondDate options:0];
        
            return (sameDay && sameMonth && (labs([dateComponents year]) % interval == 0));
        }
            break;

        default:
            break;
    }
    
    return NO;

}

- (NSDate*)firstDayOfMonth {
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    NSDateComponents* dateComponents = [calendar components:AllComponents fromDate:self];
    
    [dateComponents setDay:1];
    
    return [calendar dateFromComponents:dateComponents];
}

- (NSDate*)dateByAddingDays:(NSInteger)days {

    __autoreleasing NSDateComponents* dateComponents = [[NSDateComponents alloc] init];
    
    [dateComponents setDay:days];
    
    return [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:self options:0];
}

- (NSDate*)dateByAddingMonths:(NSInteger)months {
    __autoreleasing NSDateComponents* dateComponents = [[NSDateComponents alloc] init];
    
    [dateComponents setMonth:months];
    
    return [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:self options:0];

}

- (NSDate*)dateByAddingYears:(NSInteger)years {
    __autoreleasing NSDateComponents* dateComponents = [[NSDateComponents alloc] init];
    
    [dateComponents setYear:years];
    
    return [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:self options:0];
}

- (NSInteger)weekday {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitWeekday fromDate:self] weekday];
}

- (NSInteger)day {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:self] day];
}

- (NSInteger)month {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitMonth fromDate:self] month];
}

- (NSInteger)year {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:self] year];
}

- (NSInteger)hour {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitHour fromDate:self] hour];
}

- (NSInteger)minutes {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitMinute fromDate:self] minute];
}

- (NSInteger)numberOfDaysInMonth {
    return [[NSCalendar currentCalendar]
            rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:self].length;
}


- (BOOL)isToday {
    return ([self isEqualWithDate:[NSDate date]]);
}

- (BOOL)isTomorrow {
    return ([self isEqualWithDate:[[NSDate date] dateByAddingDays:1]]);
}

@end
