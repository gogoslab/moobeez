//
//  ConnectionViewController.m
//  Gogz
//
//  Created by Radu Banea on 10/11/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "ConnectionViewController.h"
#import "ConnectionLibrary.h"

@implementation ConnectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (ConnectionsManager*)connectionsManager {
    if (!_connectionsManager) {
        _connectionsManager = [[ConnectionsManager alloc] init];
    }
    return _connectionsManager;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)startConnection:(Connection*)connection {
    connection.activityIndicator = self.activityIndicator;
    [self.connectionsManager startConnection:connection];
}

@end
