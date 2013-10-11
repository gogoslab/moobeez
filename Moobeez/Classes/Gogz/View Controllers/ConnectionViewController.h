//
//  ConnectionViewController.h
//  Gogz
//
//  Created by Radu Banea on 10/11/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConnectionLibrary.h"

@interface ConnectionViewController : UIViewController {
    
}

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView* activityIndicator;

@property (strong, nonatomic) ConnectionsManager* connectionsManager;

- (void)startConnection:(Connection*)connection;

@end
