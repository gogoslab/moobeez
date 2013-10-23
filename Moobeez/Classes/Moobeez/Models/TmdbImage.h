//
//  TmdbImage.h
//  Moobeez
//
//  Created by Radu Banea on 10/23/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "DatabaseItem.h"

@interface TmdbImage : DatabaseItem

@property (strong, nonatomic) NSString* path;
@property (readwrite, nonatomic) CGFloat aspectRatio;

- (id)initWithTmdbDictionary:(NSDictionary *)tmdbDictionary;
- (void)addEntriesFromTmdbDictionary:(NSDictionary *)tmdbDictionary;

@end
