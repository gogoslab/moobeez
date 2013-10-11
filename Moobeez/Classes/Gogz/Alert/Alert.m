//
//  Alert.m
//  Gogz
//
//  Created by Radu Banea on 10/11/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "Alert.h"

@interface Alert () <UIAlertViewDelegate>

@property (nonatomic, copy) AlertButtonClickedCallbackBlock callbackBlock;

@end

@implementation Alert

static NSMutableArray* alerts;

+ (NSMutableArray*)alerts {
    if (!alerts) {
        alerts = [[NSMutableArray alloc] init];
    }
    return alerts;
}

+ (UIAlertView*)showAlertView:(UIAlertView *)alertView withButtonClickedCallback:(AlertButtonClickedCallbackBlock)callback {

    Alert* alert = [[Alert alloc] init];
    alert.callbackBlock = callback;
    alertView.delegate = alert;
    [alertView show];
    
    [[Alert alerts] addObject:alert];
    
    return alertView;
}

+ (UIAlertView*)showAlertView:(UIAlertView*)alertView {
    [alertView show];
    return alertView;
}

+ (UIAlertView*)showAlertViewWithTitle:(NSString *)title message:(NSString *)message buttonClickedCallback:(AlertButtonClickedCallbackBlock)callback cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitle, ... NS_REQUIRES_NIL_TERMINATION {
    
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
    
    if (otherButtonTitle)
    {
        NSString* buttonTitle = nil;
        va_list argumentList;

        [alertView addButtonWithTitle:otherButtonTitle];
        va_start(argumentList, otherButtonTitle);
        while ((buttonTitle = va_arg(argumentList, id)))
        {
            [alertView addButtonWithTitle:buttonTitle];
        }
        va_end(argumentList);
    }
    
    return [self showAlertView:alertView withButtonClickedCallback:callback];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    self.callbackBlock(buttonIndex);
    [[Alert alerts] removeObject:self];
}

@end
