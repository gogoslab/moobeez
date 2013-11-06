//
//  ActorToolboxView.h
//  Moobeez
//
//  Created by Radu Banea on 11/05/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "ToolboxView.h"
#import "TmdbCharacter.h"

@class TmdbPerson;

@interface ActorToolboxView : ToolboxView

@property (strong, nonatomic) TmdbPerson* tmdbPerson;

@property (copy, nonatomic) CharacterCellSelectionHandler characterSelectionHandler;

@end
