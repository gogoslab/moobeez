//
//  DatePickerView.m
//  Moobeez
//
//  Created by Radu Banea on 10/30/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "DatePickerView.h"
#import "Moobeez.h"

@interface DatePickerView ()

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;

@property (weak, nonatomic) IBOutlet UIView *blurView;
@property (copy, nonatomic) DatePickerCompletionHandler completionHandler;

@end

@implementation DatePickerView

+ (id)showDatePickerWithDate:(NSDate*)date inView:(UIView*)view completionHandler:(DatePickerCompletionHandler)completionHandler {
    
    DatePickerView* datePicker = [[NSBundle mainBundle] loadNibNamed:@"DatePickerView" owner:self options:nil][0];
    datePicker.frame = view.bounds;
    [view addSubview:datePicker];
    datePicker.completionHandler = completionHandler;
    
    datePicker.datePicker.date = date;
    
    [datePicker show];
    
    return datePicker;
}

- (void)awakeFromNib {
    self.blurView.tintColor = [UIColor colorWithRed:145.0/255 green:180.0/255 blue:192.0/255 alpha:1.0];

}

- (void)show {
    if (!self.superview) {
        [[UIApplication sharedApplication].keyWindow addSubview:self];
        self.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - self.frame.size.height, self.frame.size.width, self.frame.size.height);
    }
    
    self.transform = CGAffineTransformMakeTranslation(0, self.frame.size.height);
    
    [UIView beginAnimations:nil context:nil];
    self.transform = CGAffineTransformIdentity;
    [UIView commitAnimations];
}

- (void)hide {
    [UIView beginAnimations:nil context:nil];
    if (self.superview == [UIApplication sharedApplication].keyWindow) {
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(removeFromSuperview)];
    }
    self.transform = CGAffineTransformMakeTranslation(0, self.frame.size.height);
    [UIView commitAnimations];
}


- (IBAction)cancelButtonPressed:(id)sender {
    [self hide];
}

- (IBAction)saveButtonPressed:(id)sender {
    self.completionHandler(self.datePicker.date);
    [self hide];
}

- (IBAction)viewTapped:(id)sender {
    self.completionHandler(self.datePicker.date);
    [self hide];    
}

@end
