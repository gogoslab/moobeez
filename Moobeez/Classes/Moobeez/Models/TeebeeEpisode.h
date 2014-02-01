//
//  TeebeeEpisode.h
//  Moobeez
//
//  Created by Radu Banea on 30/01/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "DatabaseItem.h"

@interface TeebeeEpisode : DatabaseItem

@property (readwrite, nonatomic) NSInteger seasonNumber;
@property (readwrite, nonatomic) NSInteger episodeNumber;

@property (readwrite, nonatomic) BOOL watched;

@property (readwrite, nonatomic) NSDate* date;

@end
