//
//  NSFileManager+ExtraAtributtes.m
//  Gogz
//
//  Created by Radu Banea on 10/11/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "NSFileManager+ExtraAtributtes.h"
#import <sys/xattr.h>

#define FileAttributeAccessDate @"accessDate"

@implementation NSFileManager (ExtraAtributtes)

- (BOOL)accessFileAtPath:(NSString*)path {
    
    NSTimeInterval timeInterval = [NSDate timeIntervalSinceReferenceDate];
    
    const char *attrName = [FileAttributeAccessDate UTF8String];
    const char *filePath = [path fileSystemRepresentation];
    
    NSString* value = [NSString stringWithFormat:@"%f", timeInterval];
    
    const char *val = [value UTF8String];
    
    int result = setxattr(filePath, attrName, val, strlen(val), 0, 0);
    
    return (result != -1);
}

- (NSDate*)fileAtPathLastAccessedDate:(NSString*)path {
    
    const char *attrName = [FileAttributeAccessDate UTF8String];
    const char *filePath = [path fileSystemRepresentation];
    
    // get size of needed buffer
    int bufferLength = getxattr(filePath, attrName, NULL, 0, 0, 0);
    
    if (bufferLength <= 0) {
        [self accessFileAtPath:path];
        return [NSDate date];
    }
    
    // make a buffer of sufficient length
    char *buffer = malloc(bufferLength);
    
    // now actually get the attribute string
    getxattr(filePath, attrName, buffer, 255, 0, 0);
    
    // convert to NSString
    NSString *retString = [[NSString alloc] initWithBytes:buffer length:bufferLength encoding:NSUTF8StringEncoding];
    
    // release buffer
    free(buffer);
    
    if (retString.length) {
        return [NSDate dateWithTimeIntervalSinceReferenceDate:[retString doubleValue]];
    }
    else {
        [self accessFileAtPath:path];
        return [NSDate date];
    }
    
}
@end
