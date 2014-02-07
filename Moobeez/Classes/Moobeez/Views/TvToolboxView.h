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

@property (weak, nonatomic) Teebee* teebee;
@property (weak, nonatomic) TmdbTV* tmdbTv;

@property (copy, nonatomic) CharacterCellSelectionHandler characterSelectionHandler;

@end
