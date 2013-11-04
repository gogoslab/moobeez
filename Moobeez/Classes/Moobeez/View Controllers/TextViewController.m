//
//  TextViewController.m
//  Moobeez
//
//  Created by Radu Banea on 04/11/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "TextViewController.h"
#import "Moobeez.h"

@interface TextViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet AMBlurView *blurView;
@property (weak, nonatomic) IBOutlet UIImageView *maskView;

@property (weak, nonatomic) IBOutlet UIImageView *test;

@property (readwrite, nonatomic) CGFloat maximumContentHeight;
@end

@implementation TextViewController

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
    
    self.contentView.layer.cornerRadius = 25;
    
    self.maximumContentHeight = self.contentView.height;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    self.textView.text = self.text;
    self.textView.textAlignment = NSTextAlignmentJustified;

    int oldTextHeight = self.textView.height;
    
    [self.textView sizeToFit];
    
    self.contentView.height += self.textView.height - oldTextHeight;
    self.contentView.y -= self.textView.height - oldTextHeight;
    
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    oldTextHeight = self.contentView.height;
    
    self.contentView.height = MIN(self.contentView.height, self.maximumContentHeight);
    self.contentView.height = MAX(self.contentView.height, 100);
    
    self.contentView.y += self.contentView.height - oldTextHeight;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonPressed:(id)sender {
    [self.view removeFromSuperview];
}


@end
