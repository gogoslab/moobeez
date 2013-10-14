//
//  ImageView.h
//  ImageLoader
//
//  Created by Radu Banea on 10/11/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageLoader.h"

@interface ImageView : UIImageView {
    
}

@property (strong, nonatomic) IBOutlet UIImageView* borderImageView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView* activityIndicator;
@property (readwrite, nonatomic) BOOL resize;
@property (readwrite, nonatomic) CGRect borderExtraFrame;
@property (readwrite, nonatomic) BOOL loadSyncronized;
@property (strong, nonatomic) UIImage* defaultImage;

- (void)loadImageWithPath:(NSString*)path;
- (void)loadImageWithPath:(NSString*)path resize:(BOOL)resize;
- (void)loadImageWithPath:(NSString*)path resize:(BOOL)resize withPriority:(enum ImageLoadingPriority)priority;
- (void)loadImageWithPath:(NSString*)path withPriority:(enum ImageLoadingPriority)priority;

@end
