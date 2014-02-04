//
//  TvToolboxView.h
//  Moobeez
//
//  Created by Radu Banea on 10/23/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "ToolboxView.h"

@class Teebee;
@class TmdbTV;

@interface TvToolboxView : ToolboxView

@property (strong, nonatomic) Teebee* teebee;
@property (strong, nonatomic) TmdbTV* tmdbTv;

@property (copy, nonatomic) CharacterCellSelectionHandler characterSelectionHandler;

@end
