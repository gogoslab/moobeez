//
//  NSDateFormatter+Extensions.m
//  Gogz
//
//  Created by Radu Banea on 10/11/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "NSDateFormatter+Extensions.h"

@implementation NSDateFormatter (Extensions)

+ (NSDateFormatter*)dateFormatterWithFormat:(NSString*)dateFormat {
    __autoreleasing NSDateFormatter* df = [[NSDateFormatter alloc] init];
    [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [df setDateFormat:dateFormat];
    return df;
}

@end
