//
//  TmdbImage.h
//  Moobeez
//
//  Created by Radu Banea on 10/23/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TmdbImage : NSObject

@property (readonly, nonatomic) NSInteger id;

@property (strong, nonatomic) NSString* path;
@property (readwrite, nonatomic) CGFloat aspectRatio;

- (id)initWithTmdbDictionary:(NSDictionary *)tmdbDictionary;
- (void)addEntriesFromTmdbDictionary:(NSDictionary *)tmdbDictionary;

@end
