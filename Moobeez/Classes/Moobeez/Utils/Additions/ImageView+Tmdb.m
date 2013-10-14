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

- (void)loadImageWithPath:(NSString*)path andWidth:(NSInteger)width {
    if (!path) {
        self.image = nil;
        return;
    }
    [self loadImageWithPath:[_tmdbRootPath stringByAppendingString:[NSString stringWithFormat:@"w%ld%@", (long)width, path]]];
}
@end
