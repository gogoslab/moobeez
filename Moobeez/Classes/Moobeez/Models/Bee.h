//
//  Bee.h
//  Moobeez
//
//  Created by Radu Banea on 10/14/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "DatabaseItem.h"

@interface Bee : DatabaseItem

@property (readwrite, nonatomic) NSInteger tmdbId;
@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* comments;
@property (strong, nonatomic) NSString* posterPath;
@property (strong, nonatomic) NSString* backdropPath;
@property (readwrite, nonatomic) CGFloat rating;
@property (strong, nonatomic) NSDate* date;

@property (readonly, nonatomic) NSMutableDictionary* databaseDictionary;

- (NSComparisonResult)compareByDate:(Bee*)moobee;
- (NSComparisonResult)compareById:(Bee*)moobee;

@end
