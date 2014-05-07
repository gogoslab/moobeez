//
//  DatePickerView.h
//  Moobeez
//
//  Created by Radu Banea on 10/30/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^DatePickerCompletionHandler) (NSDate* date);

@interface DatePickerView : UIView

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

+ (id)showDatePickerWithDate:(NSDate*)date inView:(UIView*)view completionHandler:(DatePickerCompletionHandler)completionHandler;

- (void)show;
- (void)hide;

@end
