//
//  ImageView+Tmdb.m
//  Moobeez
//
//  Created by Radu Banea on 10/11/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "ImageView+Tmdb.h"

@implementation ImageView (Tmdb)

static NSString* _tmdbRootPath;

+ (void)setTmdbRootPath:(NSString*)tmdbRootPath {
    _tmdbRootPath = tmdbRootPath;
}

- (void)awakeFromNib {
    self.defaultImage = [UIImage imageNamed:@"default_image.png"];
}

+ (NSString*)imagePath:(NSString*)path forWidth:(NSInteger)width {
    return [_tmdbRootPath stringByAppendingString:[NSString stringWithFormat:@"w%ld%@", (long)width, path]];
}

- (void)loadImageWithPath:(NSString*)path andWidth:(NSInteger)width completion:(ImageViewCompletionHandler)completionHandler  {
    if (!path) {
        self.image = nil;
        return;
    }
    [self loadImageWithPath:[ImageView imagePath:path forWidth:width] completion:completionHandler];
}

- (void)loadImageWithPath:(NSString*)path andHeight:(NSInteger)height completion:(ImageViewCompletionHandler)completionHandler  {
    if (!path) {
        self.image = nil;
        return;
    }
    [self loadImageWithPath:[_tmdbRootPath stringByAppendingString:[NSString stringWithFormat:@"h%ld%@", (long)height, path]] completion:completionHandler];
}

- (void)loadOriginalImageWithPath:(NSString*)path completion:(ImageViewCompletionHandler)completionHandler  {
    if (!path) {
        self.image = nil;
        return;
    }
    [self loadImageWithPath:[_tmdbRootPath stringByAppendingFormat:@"original%@", path] completion:completionHandler];
}

@end
