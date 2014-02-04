//
//  ConnectionsManager.m
//  ConnectionLibrary
//
//  Created by Radu Banea on 10/11/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "ConnectionLibrary.h"

@interface ConnectionsManager ()

@property (strong, nonatomic) NSMutableArray* connections;

@end

@implementation ConnectionsManager

static ConnectionsManager* sharedManager;

+ (ConnectionsManager*)sharedManager {
    if (!sharedManager) {
        sharedManager = [[ConnectionsManager alloc] init];
    }
    return sharedManager;
}

- (id)init {
    self = [super init];
    
    if (self) {
        
        self.connections = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)startConnection:(Connection*)connection {
    
    if (connection.fakeConnection) {
        return;
    }
    
    [self.connections addObject:connection];
    connection.connectionManager = self;
    [connection startConnection];

}

- (void)stopConnection:(Connection*)connection {
    if (connection.fakeConnection) {
        return;
    }
    
    [self.connections removeObject:connection];
    [connection stopConnection];
}

@end
