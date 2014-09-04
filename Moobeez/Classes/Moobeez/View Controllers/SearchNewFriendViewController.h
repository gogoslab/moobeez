//
//  SearchNewFriendViewController.h
//  Moobeez
//
//  Created by Radu Banea on 04/09/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "ViewController.h"

typedef void (^SelectFriendHandler) (id selectedFriends);

@interface SearchNewFriendViewController : ViewController

@property (copy, nonatomic) SelectFriendHandler selectHandler;
@property (strong, nonatomic) NSMutableArray* selectedFriends;

@end
