//
//  MovieViewController.m
//  Moobeez
//
//  Created by Radu Banea on 10/21/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "MovieViewController.h"
#import "Moobeez.h"

#define MIN_TOOLBOX_HEIGHT 72

@interface MovieViewController ()

@property (weak, nonatomic) IBOutlet ImageView *posterImageView;

@property (strong, nonatomic) IBOutlet UIView *toolboxView;
@property (weak, nonatomic) IBOutlet UIImageView *toolboxHandlerImageView;

@property (readwrite, nonatomic) CGFloat toolboxStartPoint;
@property (readwrite, nonatomic) CGFloat delta;

@property (readwrite, nonatomic) CGFloat minToolboxY;
@property (readwrite, nonatomic) CGFloat maxToolboxY;

@end

@implementation MovieViewController

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
    
    [self.posterImageView loadImageWithPath:self.moobee.posterPath andWidth:154 completion:^(BOOL didLoadImage) {
        self.posterImageView.defaultImage = self.posterImageView.image;
        [self.posterImageView loadImageWithPath:self.moobee.posterPath andWidth:500 completion:^(BOOL didLoadImage) {}];
    }];
    
    [self.view addSubview:self.toolboxView];
    self.toolboxView.y = self.maxToolboxY;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonPressed:(id)sender {
    
    [self dismissViewControllerAnimated:NO completion:^{
        self.closeHandler();
    }];
    
}

- (IBAction)toolboxDidPan:(id)sender {
    
    UIPanGestureRecognizer* gesture = (UIPanGestureRecognizer*) sender;
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            self.toolboxStartPoint = [gesture translationInView:self.view].y;
            break;
        case UIGestureRecognizerStateChanged:
        {
            self.toolboxHandlerImageView.image = [UIImage imageNamed:@"toolbox_line.png"];

            int point = [gesture translationInView:self.view].y;
            
            int toolboxViewY = self.toolboxView.y;
            toolboxViewY += point - self.toolboxStartPoint;
            
            toolboxViewY = MAX(toolboxViewY, self.minToolboxY);
            toolboxViewY = MIN(toolboxViewY, self.maxToolboxY);
            
            self.delta = toolboxViewY - self.toolboxView.y;
            self.toolboxStartPoint += self.delta;
            
            [UIView animateWithDuration:0.05 animations:^{
                self.toolboxView.y = toolboxViewY;
            }];
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            if (abs(self.delta) > 1) {
                if (self.delta > 0) {
                    [self hideFullToolbox];
                }
                else if (self.delta < 0) {
                    [self showFullToolbox];
                }
            }
            else {
                
                CGFloat position = (self.toolboxView.y - self.minToolboxY) / (self.maxToolboxY - self.minToolboxY);
                
                if (position > 0.5) {
                    [self hideFullToolbox];
                }
                else {
                    [self showFullToolbox];
                }
            }
        }
            break;
        default:
            break;
    }
}

- (void)showFullToolbox {
    
    [UIView animateWithDuration:0.5 animations:^{
        self.toolboxView.y = self.minToolboxY;
    } completion:^(BOOL finished) {
        self.toolboxHandlerImageView.image = [UIImage imageNamed:@"toolbox_down_arrow.png"];
    }];
    
}

- (void)hideFullToolbox {
    
    [UIView animateWithDuration:0.5 animations:^{
        self.toolboxView.y = self.maxToolboxY;
    } completion:^(BOOL finished) {
        self.toolboxHandlerImageView.image = [UIImage imageNamed:@"toolbox_up_arrow.png"];
    }];
    
}

- (CGFloat)minToolboxY {
    return self.view.height - self.toolboxView.height;
}

- (CGFloat)maxToolboxY {
    return self.view.height - MIN_TOOLBOX_HEIGHT;
}




@end
