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

+ (NSString*)imagePath:(NSString*)path forWidth:(NSInteger)width;

- (void)loadImageWithPath:(NSString*)path andWidth:(NSInteger)width completion:(ImageViewCompletionHandler)completionHandler;

- (void)loadImageWithPath:(NSString*)path andHeight:(NSInteger)height completion:(ImageViewCompletionHandler)completionHandler;

- (void)loadOriginalImageWithPath:(NSString*)path completion:(ImageViewCompletionHandler)completionHandler;

- (void)loadImageWithPath:(NSString*)path type:(NSString*)type completion:(ImageViewCompletionHandler)completionHandler;

- (void)loadPosterWithPath:(NSString*)path completion:(ImageViewCompletionHandler)completionHandler;
- (void)loadProfileWithPath:(NSString*)path completion:(ImageViewCompletionHandler)completionHandler;
- (void)loadBackdropWithPath:(NSString*)path completion:(ImageViewCompletionHandler)completionHandler;

@end
