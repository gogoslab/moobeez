//
//  ImageLoader.m
//  ImageLoader
//
//  Created by Radu Banea on 10/11/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "ImageLoader.h"
#import "UIImage+Extra.h"
#import "NSObject+Mutable.h"

@interface ImageLoader ()

@property (retain, nonatomic) NSMutableArray* loadingQues;
@property (readwrite, nonatomic) NSInteger lastPriority;

@end

@implementation ImageLoader

static NSMutableDictionary* _imagesPaths;

+ (NSMutableDictionary*)imagesPaths {
    if (!_imagesPaths) {
        _imagesPaths = (NSMutableDictionary*) [[[NSUserDefaults standardUserDefaults] objectForKey:@"imagesPaths"] mutableObject];
        if (!_imagesPaths.count) {
            _imagesPaths = [NSMutableDictionary dictionary];
            [[NSUserDefaults standardUserDefaults] setObject:_imagesPaths forKey:@"imagesPaths"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    return _imagesPaths;
}

+ (void)saveImagePaths {
    [[NSUserDefaults standardUserDefaults] setObject:_imagesPaths forKey:@"imagesPaths"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

static ImageLoader* sharedLoader;

+ (ImageLoader*)sharedLoader {
    if (!sharedLoader) {
        sharedLoader = [[ImageLoader alloc] init];
    }
    return sharedLoader;
}

@synthesize imagePath;
@synthesize busy;


- (id)init {
    self = [super init];
    
    if (self) {
        self.loadingQues = [NSMutableArray array];
        for (int i = 0; i < ImageLoadingPrioritiesCount; ++i) {
            [self.loadingQues addObject:[NSMutableArray array]];
        }
        self.lastPriority = -1;
    }
    
    return self;
}

- (NSString*)loadImageWithPath:(NSString*)path resizeToSize:(CGSize)size withPriority:(enum ImageLoadingPriority)priority {
    
    @try {

        self.resizeToSize = size;
    
    NSString* offlinePath = [[ImageLoader imagesPaths] objectForKey:path];
    
    if (offlinePath) {
        NSString* absolutePath = [offlineRootPath stringByAppendingPathComponent:offlinePath];
        
        UIImage* image = [UIImage imageWithContentsOfFile:absolutePath];
        
        if (image) {
            self.imageConnection = nil;
            return nil;
        }
        else {
            for (int i = 0; i < self.loadingQues.count; ++i) {
                for (int j = 0; j < [self.loadingQues[i] count]; ++j) {
                    NSString* onlinePath = self.loadingQues[i][j];
                    if ([onlinePath isEqualToString:path]) {
                        if (i != priority) {
                            [self.loadingQues[i] removeObject:path];
                            break;
                        }
                        else {
                            return offlinePath;
                        }
                    }
                }
            }
        }
    }
    else {
        CFUUIDRef uuidObj = CFUUIDCreate(nil);
        offlinePath = (NSString*) CFBridgingRelease(CFUUIDCreateString(nil, uuidObj));
        CFRelease(uuidObj);
        
        [[ImageLoader imagesPaths] setObject:offlinePath forKey:path];
        [ImageLoader saveImagePaths];
    }
    
    [self.loadingQues[priority] addObject:path];
    
    if (!self.imageConnection) {
        [self nextConnection];
    }
    
        return offlinePath;
    }
    @catch (NSException *exception) {
        NSLog(@"error path: %@", path);
        return @"";
    }
    @finally {
    }

}

- (void)nextConnection {

    if (self.lastPriority != -1 && [self.loadingQues[self.lastPriority] count] > 0) {
        [self.loadingQues[self.lastPriority] removeObjectAtIndex:0];
    }
    
    self.lastPriority = -1;
    
    for (int priority = 0; priority < ImageLoadingPrioritiesCount; ++priority) {
        if ([self.loadingQues[priority] count] > 0) {
            self.lastPriority = priority;
            break;
        }
    }
    
    if (self.lastPriority == -1) {
        self.imageConnection = nil;
        return;
    }

    NSString* onlinePath = self.loadingQues[self.lastPriority][0];
    
    NSString* absolutePath = onlinePath;
    
    absolutePath = [absolutePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString* offlinePath = [[ImageLoader imagesPaths] objectForKey:onlinePath];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:absolutePath]];
	[request setTimeoutInterval:10];
	[request setHTTPMethod:@"GET"];
    
    self.imageConnection = [[URLConnection alloc] initWithRequest:request delegate:self];
    self.imageConnection.responseData = [NSMutableData data];
    self.imageConnection.userInfo = [NSMutableDictionary dictionaryWithObject:onlinePath forKey:@"onlinePath"];
    [self.imageConnection.userInfo setObject:offlinePath forKey:@"offlinePath"];
    
    self.busy = YES;
}

- (NSString*)loadImageWithPath:(NSString *)path {
    return [self loadImageWithPath:path resizeToSize:CGSizeZero withPriority:ImageLoadingPriorityMedium];
}

- (NSString*)loadImageWithPath:(NSString *)path withPriority:(enum ImageLoadingPriority)priority {
    return [self loadImageWithPath:path resizeToSize:CGSizeZero withPriority:priority];
}

- (void)changePriorityForPath:(NSString*)path toPriority:(enum ImageLoadingPriority)priority {
    for (int i = 0; i < self.loadingQues.count; ++i) {
        for (int j = 0; j < [self.loadingQues[i] count]; ++j) {
            NSString* onlinePath = self.loadingQues[i][j];
            if ([onlinePath isEqualToString:path]) {
                if (i != priority) {
                    [self.loadingQues[i] removeObject:path];
                    [self.loadingQues[priority] addObject:path];
                    if (self.lastPriority == i && j == 0) {
                        self.lastPriority = priority;
                    }
                    break;
                }
            }
        }
    }
}

- (void)connection:(URLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	[connection.responseData setLength:0];
}

- (void)connection:(URLConnection *)connection didReceiveData:(NSData *)data
{
	[connection.responseData appendData:data];
}

- (void)connection:(URLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"eror connection:%@",error);
	
    self.imageConnection = nil;
    
    self.busy = NO;
    
	[[NSNotificationCenter defaultCenter] postNotificationName:DidFailToLoadImageNotification object:self];
	
}

- (void)connectionDidFinishLoading:(URLConnection *)connection
{
    self.busy = NO;
    
    NSString* offlinePath = [connection.userInfo objectForKey:@"offlinePath"];
    
    NSString* absoluteOfflinePath = [offlineRootPath stringByAppendingPathComponent:offlinePath];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[absoluteOfflinePath stringByDeletingLastPathComponent]]) {
        NSError* error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:[absoluteOfflinePath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"error: %@",error);
        }
    }
    if (CGSizeEqualToSize(self.resizeToSize, CGSizeZero)) {
        [connection.responseData writeToFile:absoluteOfflinePath atomically:YES];
    }
    else {
        UIImage* image = [UIImage imageWithData:connection.responseData];
        
        float scale = MAX(image.size.width / self.resizeToSize.width, image.size.height / self.resizeToSize.height);

        image = [image scaledToSize:CGSizeMake(image.size.width / scale, image.size.height / scale)];
        
        NSData* data = UIImageJPEGRepresentation(image, 1.0);
        [data writeToFile:absoluteOfflinePath atomically:YES];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DidLoadImageNotification object:offlinePath];
    
    [self performSelector:@selector(nextConnection) withObject:nil afterDelay:0.01];
}

@end
