//
//  LoadingViewController.m
//  Moobeez
//
//  Created by Radu Banea on 10/14/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "LoadingViewController.h"
#import "Moobeez.h"

@interface LoadingViewController ()

@end

@implementation LoadingViewController

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
    
    ConfigurationConnection* connection = [[ConfigurationConnection alloc] initWithCompletionHandler:^(WebserviceResultCode code) {
        if (code == WebserviceResultOk) {
            [self.navigationController pushViewController:self.appDelegate.tabBarController animated:NO];
        }
    }];
    
    [self startConnection:connection];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
