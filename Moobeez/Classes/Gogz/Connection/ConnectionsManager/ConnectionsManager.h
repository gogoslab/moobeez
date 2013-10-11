//
//  ConnectionsManager.h
//  ConnectionLibrary
//
//  Created by Radu Banea on 10/11/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConnectionsManager : NSObject

@property (readonly, nonatomic) NSMutableArray* connections;

+ (ConnectionsManager*)sharedManager;

- (void)startConnection:(Connection*)connection;
- (void)stopConnection:(Connection*)connection;

@end
