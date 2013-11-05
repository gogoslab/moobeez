//
//  CastViewController.h
//  Moobeez
//
//  Created by Radu Banea on 05/11/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "ViewController.h"
#import "TmdbCharacter.h"

@interface CastViewController : ViewController

@property (strong, nonatomic) NSArray* castArray;
@property (strong, nonatomic) UIView* sourceButton;

@property (copy, nonatomic) CharacterSelectionHandler characterSelectionHandler;

- (void)startAnimation;


@end
