//
//  Alert.h
//  Gogz
//
//  Created by Radu Banea on 10/11/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^AlertButtonClickedCallbackBlock) (NSInteger buttonIndex);

@interface Alert : NSObject

+ (UIAlertView*)showAlertView:(UIAlertView *)alertView withButtonClickedCallback:(AlertButtonClickedCallbackBlock)callback;
+ (UIAlertView*)showAlertView:(UIAlertView*)alertView;
+ (UIAlertView*)showAlertViewWithTitle:(NSString *)title message:(NSString *)message buttonClickedCallback:(AlertButtonClickedCallbackBlock)callback cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitle, ... NS_REQUIRES_NIL_TERMINATION;
@end
