//
//  RWBlurPopover.m
//  RWBlurPopover
//
//  Created by Bin Zhang on 13-4-19.
//  Copyright (c) 2013年 Fresh-Ideas Studio. All rights reserved.
//

#import <sys/types.h>
#import <sys/sysctl.h>
#import <QuartzCore/QuartzCore.h>
#import "GPUImage.h"
#import "RWBlurPopover.h"

@interface UIDevice (Platform)

- (NSString *)platform;

@end

@implementation UIDevice (Platform)

- (NSString *) platform
{
    // https://gist.github.com/Jaybles/1323251
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    machine = nil;
    return platform;
}

@end

@interface RWBlurPopover ()

@property (nonatomic, strong) UIImage *origImage;
@property (nonatomic, strong) UIImageView *blurredImageView;
@property (nonatomic, strong) UIView *coverView;
@property (nonatomic, strong) UIViewController *contentViewController;
@property (nonatomic, strong) UIView *contentView;

@end

@implementation RWBlurPopover

- (BOOL)shouldWorkOnThisDevice
{
    if (!self.skipOldDevices)
    {
        return YES;
    }
    
    NSString *platform = [[UIDevice currentDevice] platform];
    if ([platform hasPrefix:@"iPhone"] && [platform compare:@"iPhone4,1"] == NSOrderedAscending)
    {
        return NO;
    }
    if ([platform hasPrefix:@"iPod"] && [platform compare:@"iPod5,1"] == NSOrderedAscending)
    {
        return NO;
    }
    if ([platform hasPrefix:@"iPad"] && [platform compare:@"iPad2,1"] == NSOrderedAscending)
    {
        return NO;
    }
    return YES;
}

+ (instancetype)instance
{
    static RWBlurPopover *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [RWBlurPopover new];
    });
    return _instance;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.contentView = [[UIView alloc] initWithFrame:CGRectZero];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.contentView.alpha = 1.0;
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

- (UIImage *)imageFromView:(UIView *)v
{
    CGSize size = v.bounds.size;
    
    CGFloat scale = [UIScreen mainScreen].scale;
    size.width *= scale;
    size.height *= scale;
    
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextScaleCTM(ctx, scale, scale);
    
    [v.layer renderInContext:ctx];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)prepareBlurredImage
{
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    // add a cover on top of rootViewController.view, to disable user interactions
    self.coverView = [[UIView alloc] initWithFrame:rootViewController.view.bounds];
    self.coverView.backgroundColor = [UIColor clearColor];
    UIImageView *coverImageView = [[UIImageView alloc] initWithFrame:self.coverView.bounds];
    coverImageView.backgroundColor = [UIColor clearColor];
    [self.coverView addSubview:coverImageView];
    [rootViewController.view addSubview:self.coverView];
    
    if (![self shouldWorkOnThisDevice])
    {
        return;
    }
    
    self.origImage = [self imageFromView:rootViewController.view];
    coverImageView.image = self.origImage;
    
    self.blurredImageView = [[UIImageView alloc] initWithFrame:rootViewController.view.bounds];
    self.blurredImageView.backgroundColor = [UIColor clearColor];
    self.blurredImageView.alpha = 0;
    [rootViewController.view addSubview:self.blurredImageView];
}

- (void)presentBlurredViewAnimated:(BOOL)animated
{
    if (![self shouldWorkOnThisDevice])
    {
        return;
    }
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"before filter");

        GPUImageiOSBlurFilter *filter = [[GPUImageiOSBlurFilter alloc] init];
        filter.blurRadiusInPixels = [UIScreen mainScreen].scale * 4;
        weakSelf.blurredImageView.image = [filter imageByFilteringImage:weakSelf.origImage];
        NSLog(@"after filter");
        weakSelf.origImage = nil;
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (animated)
            {
                [UIView animateWithDuration:0.4 animations:^{
                    weakSelf.blurredImageView.alpha = 1.0;
                } completion:^(BOOL finished) {
                }];
            }
            else
            {
                weakSelf.blurredImageView.alpha = 1.0;
            }
        });
    });
}

- (void)removeBlurredViewAnimated:(BOOL)animated
{
    if (!animated)
    {
        [self.coverView removeFromSuperview];
        self.coverView = nil;
        [self.blurredImageView removeFromSuperview];
        self.blurredImageView = nil;
    }
    else
    {
        [self.coverView removeFromSuperview];
        self.coverView = nil;
        [UIView animateWithDuration:0.4 animations:^{
            self.blurredImageView.alpha = 0;
        } completion:^(BOOL finished) {
            [self.blurredImageView removeFromSuperview];
            self.blurredImageView = nil;
        }];
    }
}

- (void)presentViewController:(UIViewController *)viewController withHeight:(CGFloat)height
{
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    self.contentViewController = viewController;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [self prepareBlurredImage];
        self.contentViewController.modalPresentationStyle = UIModalPresentationFormSheet;
        [rootViewController presentModalViewController:self.contentViewController animated:YES];
        [self presentBlurredViewAnimated:YES];
    }
    else
    {
        self.contentView.frame = CGRectMake(0,
                                            rootViewController.view.bounds.size.height,
                                            rootViewController.view.bounds.size.width,
                                            height
                                            );
        [self.contentView addSubview:self.contentViewController.view];
        self.contentViewController.view.frame = self.contentView.bounds;
        
        [rootViewController viewWillDisappear:YES];
        // [rootViewController.view addSubview:self.contentView];
        [[UIApplication sharedApplication].keyWindow addSubview:self.contentView];
        
        [self.contentViewController viewWillAppear:YES];
        
        [UIView animateWithDuration:0.4 animations:^{
            self.contentView.frame = CGRectMake(0,
                                                rootViewController.view.bounds.size.height - height,
                                                rootViewController.view.bounds.size.width,
                                                height
                                                );
        } completion:^(BOOL finished) {
            [self prepareBlurredImage];
            [self presentBlurredViewAnimated:YES];
            [self.contentViewController viewDidAppear:YES];
            [rootViewController viewDidDisappear:YES];
        }];
    }
    
}

- (void)dismissViewControllerAnimated:(BOOL)animated completion:(void (^)(void))completion
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [self removeBlurredViewAnimated:YES];
        [[UIApplication sharedApplication].keyWindow.rootViewController dismissModalViewControllerAnimated:YES];
        if (completion)
        {
            completion();
        }
    }
    else
    {
        [self.contentViewController viewWillDisappear:YES];
        [[UIApplication sharedApplication].keyWindow.rootViewController viewWillAppear:YES];
        [UIView animateWithDuration:0.4 animations:^{
            CGRect rect = self.contentView.frame;
            rect.origin.y += rect.size.height;
            self.contentView.frame = rect;
            self.blurredImageView.alpha = 0;
        } completion:^(BOOL finished) {
            [self.contentView removeFromSuperview];
            [self.contentViewController.view removeFromSuperview];
            [[UIApplication sharedApplication].keyWindow.rootViewController viewDidAppear:YES];
            [self.contentViewController viewDidDisappear:YES];
            self.contentViewController = nil;
            [self removeBlurredViewAnimated:NO];
            if (completion)
            {
                completion();
            }
        }];
    }
    
}

@end
