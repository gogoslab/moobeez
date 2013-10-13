//
//  URLParameters.h
//  Moobeez
//
//  Created by Radu Banea on 10/14/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (Parameters)

@property (readonly, nonatomic) NSDictionary* parametersDictionary;

@end

@interface NSString (Parameters)

@property (readonly, nonatomic) NSDictionary* parametersDictionary;

@end

@interface NSDictionary (Parameters)

@property (readonly, nonatomic) NSString* parametersString;
@property (readonly, nonatomic) NSURL* parametersURL;

@end
