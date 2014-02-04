//
//  NSNull+ErrorHandlers.h
//  Moobeez
//
//  Created by Radu Banea on 04/02/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNull (ErrorHandlers)

- (NSInteger)integerValue;
- (CGFloat)floatValue;
- (NSInteger)lenght;
- (BOOL)isEqualToString:(NSString*)string;


@end
