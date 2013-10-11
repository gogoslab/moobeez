//
//  NSFileManager+ExtraAtributtes.h
//  Gogz
//
//  Created by Radu Banea on 10/11/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (ExtraAtributtes)

- (BOOL)accessFileAtPath:(NSString*)path;
- (NSDate*)fileAtPathLastAccessedDate:(NSString*)path;

@end
