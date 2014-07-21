//
//  CheckinViewController.h
//  Moobeez
//
//  Created by Radu Banea on 17/07/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "ViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <CoreLocation/CoreLocation.h>

#import "PlacePickerViewController.h"

@interface CheckinViewController : PlacePickerViewController <UISearchDisplayDelegate, UISearchBarDelegate>

@end
