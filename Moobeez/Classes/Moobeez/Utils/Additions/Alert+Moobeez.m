//
//  Alert+Moobeez.m
//  Moobeez
//
//  Created by Radu Banea on 07/02/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "Alert+Moobeez.h"

@implementation Alert (Moobeez)

+ (UIAlertView*)showDatabaseUpdateErrorAlert {
    
    return [Alert showAlertViewWithTitle:@"Error" message:@"An error occured while trying to update the database, please try again" buttonClickedCallback:^(NSInteger buttonIndex) {} cancelButtonTitle:@"Ok" otherButtonTitles:nil];
}

@end
