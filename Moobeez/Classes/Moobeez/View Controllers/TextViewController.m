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
@property (weak, nonatomic) IBOutlet BubblePopupView *contentView;

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
    
    self.maximumContentHeight = self.contentView.height;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)setText:(NSString *)text {
    _text = text;
    
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
    
    CGPoint sourceCenter = [self.sourceButton.superview convertPoint:self.sourceButton.center toView:self.view];
    
    CGPoint bubbleSourceCenter = [self.contentView.sourceButton.superview convertPoint:self.contentView.sourceButton.center toView:self.view];
    
    self.contentView.x += sourceCenter.x - bubbleSourceCenter.x;
    self.contentView.y += sourceCenter.y - bubbleSourceCenter.y;
}

- (void)startAnimation {
    
    self.textView.hidden = YES;
    
    [self.contentView startAnimation];
    self.contentView.animationCompletionHandler = ^{
        self.textView.hidden = NO;
    };
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
