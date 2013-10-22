//
//  ImageView.m
//  ImageLoader
//
//  Created by Radu Banea on 10/11/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "ImageView.h"

@interface ImageView ()

@property (retain, nonatomic) NSString* onlinePath;
@property (retain, nonatomic) NSString* offlinePath;
@property (retain, nonatomic) ImageLoader* imageLoader;

@end

@implementation ImageView

@synthesize activityIndicator = _activityIndicator;

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        self.activityIndicator.hidesWhenStopped = YES;
        self.activityIndicator.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
        self.activityIndicator.autoresizingMask = UIViewAutoresizingNone;
        
        self.imageLoader = [[ImageLoader alloc] init];
        
        self.borderExtraFrame = CGRectZero;
    }
    
    return self;
}

- (void)loadImageWithPath:(NSString*)path resize:(BOOL)resize withPriority:(enum ImageLoadingPriority)priority completion:(ImageViewCompletionHandler)completionHandler {
    
    self.completionHandler = completionHandler;
    
#ifdef OFFLINE
    self.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[path stringByDeletingPathExtension] ofType:[path pathExtension]]];
    return;
#endif
    
    path = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    if (self.offlinePath) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:DidLoadImageNotification object:self.offlinePath];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:DidFailToLoadImageNotification object:self.offlinePath];
        [self.imageLoader changePriorityForPath:self.onlinePath toPriority:ImageLoadingPriorityLow];
    }
    
    self.resize = resize;
    
    [self.activityIndicator startAnimating];
    
    self.image = nil;
    
    self.borderImageView.hidden = YES;
    
    CGSize size = self.frame.size;
    
    if ([UIScreen mainScreen].scale == 2.0) {
        size = CGSizeMake(size.width * 2.0, size.height * 2.0);
    }
    
    NSString* offlinePath = [self.imageLoader loadImageWithPath:path resizeToSize:size withPriority:priority];
    
    if (offlinePath) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLoadImage) name:DidLoadImageNotification object:offlinePath];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFailToLoadImage) name:DidFailToLoadImageNotification object:offlinePath];
        self.offlinePath = offlinePath;
    }
    else {
        self.offlinePath = [[ImageLoader imagesPaths] objectForKey:path];
        [self didLoadImage];
    }
    self.onlinePath = path;
}

- (void)loadImageWithPath:(NSString *)path completion:(ImageViewCompletionHandler)completionHandler {
    [self loadImageWithPath:path resize:NO completion:completionHandler];
}

- (void)loadImageWithPath:(NSString *)path resize:(BOOL)resize completion:(ImageViewCompletionHandler)completionHandler {
    [self loadImageWithPath:path resize:resize withPriority:ImageLoadingPriorityMedium completion:completionHandler];
}

- (void)loadImageWithPath:(NSString *)path withPriority:(enum ImageLoadingPriority)priority completion:(ImageViewCompletionHandler)completionHandler {
    [self loadImageWithPath:path resize:NO withPriority:priority completion:completionHandler];
}

- (void)didLoadImage {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DidLoadImageNotification object:self.offlinePath];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DidFailToLoadImageNotification object:self.offlinePath];

    UIImage* image = [UIImage imageWithContentsOfFile:[offlineRootPath stringByAppendingPathComponent:self.offlinePath]];
    
    self.image = image;
    
    [self.activityIndicator stopAnimating];
    
    self.completionHandler(image != nil);
    
}

- (void)setImage:(UIImage *)image {
    if (!image) {
        super.image = self.defaultImage;
    }
    else {
        super.image = image;
    }
    
    float scaleFactor = MIN(self.frame.size.width / self.image.size.width, self.frame.size.height / self.image.size.height);
    float widthScale = scaleFactor * self.image.size.width / self.frame.size.width;
    float heightScale = scaleFactor * self.image.size.height / self.frame.size.height;
    
    self.borderImageView.frame = CGRectMake(0, 0, widthScale * self.borderImageView.image.size.width, heightScale * self.borderImageView.image.size.height + self.borderExtraFrame.size.height);
    
    //self.borderImageView.center = self.center;
    self.borderImageView.center = CGPointMake(self.center.x, self.center.y + self.borderExtraFrame.origin.y);
    
    self.borderImageView.hidden = (self.image == nil);
}

- (void)didFailToLoadImage {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DidLoadImageNotification object:self.offlinePath];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DidFailToLoadImageNotification object:self.offlinePath];
    
    [self.activityIndicator stopAnimating];
    
    self.completionHandler(NO);
}

- (void)setLoadSyncronized:(BOOL)loadSyncronized {
    if (_loadSyncronized == loadSyncronized) {
        return;
    }
    
    _loadSyncronized = loadSyncronized;
    
    if (loadSyncronized) {
        self.imageLoader = [ImageLoader sharedLoader];
    }
    else {
        self.imageLoader = [[ImageLoader alloc] init];
    }
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DidLoadImageNotification object:self.offlinePath];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DidFailToLoadImageNotification object:self.offlinePath];
    
    self.imageLoader = nil;
}
                  
@end
