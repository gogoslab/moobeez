//
//  TimelineItem.h
//  Moobeez
//
//  Created by Radu Banea on 12/08/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "DatabaseItem.h"

@interface TimelineItem : DatabaseItem

@property (strong, nonatomic) NSString* name;
@property (readwrite, nonatomic) NSInteger tmdbId;
@property (strong, nonatomic) NSString* backdropPath;
@property (strong, nonatomic) NSDate* date;
@property (readwrite, nonatomic) NSInteger season;
@property (readwrite, nonatomic) NSInteger episode;
@property (readwrite, nonatomic) CGFloat rating;

@property (readonly, nonatomic) BOOL isMovie;


@property (readonly, nonatomic) NSMutableDictionary* databaseDictionary;

- (NSComparisonResult)compareByDate:(TimelineItem*)moobee;
- (NSComparisonResult)compareDescByDate:(TimelineItem*)moobee;
- (NSComparisonResult)compareById:(TimelineItem*)moobee;

@end
