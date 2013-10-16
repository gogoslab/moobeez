//
//  ImageView.h
//  ImageLoader
//
//  Created by Radu Banea on 10/11/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageLoader.h"

typedef void (^ImageViewCompletionHandler) (BOOL didLoadImage);

@interface ImageView : UIImageView {
    
}

@property (strong, nonatomic) IBOutlet UIImageView* borderImageView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView* activityIndicator;
@property (readwrite, nonatomic) BOOL resize;
@property (readwrite, nonatomic) CGRect borderExtraFrame;
@property (readwrite, nonatomic) BOOL loadSyncronized;
@property (strong, nonatomic) UIImage* defaultImage;

@property (copy, nonatomic) ImageViewCompletionHandler completionHandler;

- (void)loadImageWithPath:(NSString*)path completion:(ImageViewCompletionHandler)completionHandler;
- (void)loadImageWithPath:(NSString*)path resize:(BOOL)resize completion:(ImageViewCompletionHandler)completionHandler;
- (void)loadImageWithPath:(NSString*)path resize:(BOOL)resize withPriority:(enum ImageLoadingPriority)priority completion:(ImageViewCompletionHandler)completionHandler;
- (void)loadImageWithPath:(NSString*)path withPriority:(enum ImageLoadingPriority)priority completion:(ImageViewCompletionHandler)completionHandler;

@end
