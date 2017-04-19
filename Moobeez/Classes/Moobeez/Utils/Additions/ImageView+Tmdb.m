//
//  ImageView+Tmdb.m
//  Moobeez
//
//  Created by Radu Banea on 10/11/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "ImageView+Tmdb.h"
#import "Constants.h"

@interface NSString (ImageTmdb)

@end

@implementation NSString (ImageTmdb)

- (NSInteger)sizeValue {
    return [[self substringFromIndex:1] integerValue];
}

- (NSString*)sizeType {
    return [self substringToIndex:1];
}

@end

@implementation ImageView (Tmdb)

static NSString* _tmdbRootPath;
static NSDictionary* _imagesSettings = nil;

+ (NSDictionary*)imagesSettings {
    if (!_imagesSettings) {
        _imagesSettings = [[NSMutableDictionary alloc] initWithContentsOfFile:[GROUP_PATH stringByAppendingPathComponent:@"ImagesSettings.plist"]];
    }
    return _imagesSettings;
}

+ (void)setTmdbRootPath:(NSString*)tmdbRootPath {
    _tmdbRootPath = tmdbRootPath;
}

- (void)awakeFromNib {
    [super awakeFromNib];

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

- (void)loadImageWithPath:(NSString*)path type:(NSString*)type size:(CGSize)imageSize completion:(ImageViewCompletionHandler)completionHandler {
    
    NSArray* sizes = [ImageView imagesSettings][[NSString stringWithFormat:@"%@_sizes", type]];
    
    for (NSString* size in sizes) {
        if (![size isEqualToString:@"original"]) {
            NSInteger value = [size sizeValue];
            if ([[size sizeType] isEqualToString:@"w"]) {
                if (value >= imageSize.width * [UIScreen mainScreen].scale * 0.8) {
                    [self loadImageWithPath:path andWidth:value completion:completionHandler];
                    return;
                }
            }
            else if ([[size sizeType] isEqualToString:@"h"]) {
                if (value >= imageSize.height * [UIScreen mainScreen].scale * 0.8) {
                    [self loadImageWithPath:path andHeight:value completion:completionHandler];
                    return;
                }
            }
        }
        else {
            [self loadOriginalImageWithPath:path completion:completionHandler];
        }
    }
    
}

- (void)loadPosterWithPath:(NSString*)path completion:(ImageViewCompletionHandler)completionHandler  {
    [self loadPosterWithPath:path size:self.frame.size completion:completionHandler];
}

- (void)loadPosterWithPath:(NSString*)path size:(CGSize)size completion:(ImageViewCompletionHandler)completionHandler  {
    [self loadImageWithPath:path type:@"poster" size:size completion:completionHandler];
}

- (void)loadProfileWithPath:(NSString*)path completion:(ImageViewCompletionHandler)completionHandler  {
    [self loadProfileWithPath:path size:self.frame.size completion:completionHandler];
}

- (void)loadProfileWithPath:(NSString*)path size:(CGSize)size completion:(ImageViewCompletionHandler)completionHandler  {
    [self loadImageWithPath:path type:@"profile" size:size completion:completionHandler];
}

- (void)loadBackdropWithPath:(NSString*)path completion:(ImageViewCompletionHandler)completionHandler  {
    [self loadBackdropWithPath:path size:self.frame.size completion:completionHandler];
}

- (void)loadBackdropWithPath:(NSString*)path size:(CGSize)size completion:(ImageViewCompletionHandler)completionHandler  {
    [self loadImageWithPath:path type:@"backdrop" size:size completion:completionHandler];
}


@end
