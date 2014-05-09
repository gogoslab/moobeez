//
//  SearchConnection.h
//  Moobeez
//
//  Created by Radu Banea on 05/09/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "TmdbConnection.h"

typedef enum : NSUInteger {
    SearchTypeMovie,
    SearchTypeTvShow,
    SearchTypePeople,
} SearchConnectionType;

typedef void (^ConnectionSearchHandler) (WebserviceResultCode code, NSMutableArray* results, NSInteger numberOfPages);

@interface SearchConnection : TmdbConnection

- (id)initWithQuery:(NSString*)query type:(SearchConnectionType)type page:(NSInteger)page completionHandler:(ConnectionSearchHandler)handler;

@property (readonly, nonatomic) BOOL areMoreResults;

@end
