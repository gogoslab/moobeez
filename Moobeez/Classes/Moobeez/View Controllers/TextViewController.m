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
@property (weak, nonatomic) IBOutlet UITextView *tempTextView;
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
    
    self.tempTextView.hidden = NO;
    self.tempTextView.text = self.text;
    self.tempTextView.textAlignment = NSTextAlignmentJustified;
   
    int oldTextHeight = self.tempTextView.height;
    
    CGSize size = [self.tempTextView sizeThatFits:CGSizeMake(self.textView.width, FLT_MAX)];
    
    int newTextHeight = size.height * 1.1;
    
    self.contentView.height += newTextHeight - oldTextHeight;
    self.contentView.y -= newTextHeight - oldTextHeight;
    
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    oldTextHeight = self.contentView.height;
    
    self.contentView.height = MIN(self.contentView.height, self.maximumContentHeight);
    self.contentView.height = MAX(self.contentView.height, 100);
    
    self.contentView.y += self.contentView.height - oldTextHeight;
     
    
    CGPoint sourceCenter = [self.sourceButton.superview convertPoint:self.sourceButton.center toView:self.view];
    
    CGPoint bubbleSourceCenter = [self.contentView.sourceButton.superview convertPoint:self.contentView.sourceButton.center toView:self.view];
    
    self.contentView.x += sourceCenter.x - bubbleSourceCenter.x;
    self.contentView.y += sourceCenter.y - bubbleSourceCenter.y;

    self.tempTextView.hidden = YES;

}

- (void)startAnimation {
    
    self.textView.hidden = YES;
    
    [self.contentView startAnimation];
    self.contentView.animationCompletionHandler = ^{
        self.textView.hidden = NO;
        self.textView.text = self.text;
        self.textView.textAlignment = NSTextAlignmentJustified;
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
