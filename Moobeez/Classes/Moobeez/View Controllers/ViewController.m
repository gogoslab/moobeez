//
//  ViewController.m
//  Moobeez
//
//  Created by Radu Banea on 10/11/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "ViewController.h"
#import "Moobeez.h"

@interface ViewController ()

@end

@implementation ViewController

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (AppDelegate*)appDelegate {
    return (AppDelegate*) [UIApplication sharedApplication].delegate;
}

- (ViewController*)previousViewController {
    @try {
        return self.navigationController.viewControllers[[self.navigationController.viewControllers indexOfObject:self] - 1];
    }
    @catch (NSException *exception) {
        return nil;
    }
    @finally {
    }
}

@end
