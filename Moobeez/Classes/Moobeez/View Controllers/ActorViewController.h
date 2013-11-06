//
//  ActorViewController.h
//  Moobeez
//
//  Created by Radu Banea on 11/05/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "ViewController.h"
#import "Constants.h"

@class Moobee;
@class TmdbPerson;

@interface ActorViewController : ViewController

@property (strong, nonatomic) TmdbPerson* tmdbActor;

@property (copy, nonatomic) EmptyHandler closeHandler;

@end
