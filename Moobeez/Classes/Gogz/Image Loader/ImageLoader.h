//
//  ImageLoader.h
//  ImageLoader
//
//  Created by Radu Banea on 10/11/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "URLConnection.h"

#define DidLoadImageNotification @"DidLoadImageNotification"
#define DidFailToLoadImageNotification @"DidFailToLoadImageNotification"

#define offlineRootPath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Images"]

enum ImageLoadingPriority {
    ImageLoadingPriorityHigh = 0,
    ImageLoadingPriorityMedium,
    ImageLoadingPriorityLow,
    ImageLoadingPrioritiesCount
    };

@interface ImageLoader : NSObject {

}

@property (nonatomic, retain) URLConnection* imageConnection;
@property (nonatomic, retain) NSString* imagePath;
@property (readwrite) BOOL busy;
@property (readwrite) CGSize resizeToSize;

+ (ImageLoader*)sharedLoader;
+ (NSMutableDictionary*)imagesPaths;


- (NSString*)loadImageWithPath:(NSString*)path resizeToSize:(CGSize)size withPriority:(enum ImageLoadingPriority)priority;
- (NSString*)loadImageWithPath:(NSString*)path withPriority:(enum ImageLoadingPriority)priority;
- (NSString*)loadImageWithPath:(NSString*)path;

- (void)changePriorityForPath:(NSString*)path toPriority:(enum ImageLoadingPriority)priority;

@end
