//
//  ViewController.h
//  Moobeez
//
//  Created by Radu Banea on 10/11/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "ConnectionViewController.h"

@class AppDelegate;

@interface ViewController : ConnectionViewController

@property (readonly, nonatomic) AppDelegate* appDelegate;

@property (readonly, nonatomic) ViewController* previousViewController;

@end
