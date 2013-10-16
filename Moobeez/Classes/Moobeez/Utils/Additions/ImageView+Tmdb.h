//
//  ImageView+Tmdb.h
//  Moobeez
//
//  Created by Radu Banea on 10/11/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "ImageView.h"

@interface ImageView (Tmdb)

+ (void)setTmdbRootPath:(NSString*)tmdbRootPath;

- (void)loadImageWithPath:(NSString*)path andWidth:(NSInteger)width completion:(ImageViewCompletionHandler)completionHandler;

@end
