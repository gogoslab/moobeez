//
//  ImagesViewController.m
//  Moobeez
//
//  Created by Radu Banea on 07/11/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "ImagesViewController.h"
#import "Moobeez.h"

@interface ImagesViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (readwrite, nonatomic) BOOL didLoadImages;

@property (strong, nonatomic) NSMutableArray* imageViewsArray;

@end

@implementation ImagesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if (!self.didLoadImages) {
        
        self.imageViewsArray = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < self.images.count; ++i) {
            
            ImageView* imageView = [[ImageView alloc] initWithFrame:self.scrollView.bounds];
            imageView.x = i * imageView.width;
            imageView.autoresizesSubviews = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            
            imageView.loadSyncronized = YES;
            imageView.defaultImage = nil;
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            
            [self.scrollView addSubview:imageView];
            self.scrollView.contentSize = CGSizeMake(self.scrollView.width * self.images.count, self.scrollView.height);
            
            [self.imageViewsArray addObject:imageView];
        }
        
        self.didLoadImages = YES;
        
        [self loadImageAtIndex:@0];
    }

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)loadImageAtIndex:(NSNumber*)index {
    
    int i = [index intValue];
    
    if (i >= self.images.count) {
        return;
    }
    
    [self.imageViewsArray[i] loadOriginalImageWithPath:((TmdbImage*) self.images[i]).path completion:^(BOOL didLoadImage) {}];

    [self performSelector:@selector(loadImageAtIndex:) withObject:[NSNumber numberWithInt:i + 1] afterDelay:0.05];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeLeft;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (IBAction)backButtonPressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{}];
    
}


@end
