//
//  MovieToolboxView.h
//  Moobeez
//
//  Created by Radu Banea on 10/23/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "ToolboxView.h"

@class Moobee;
@class TmdbMovie;

@interface MovieToolboxView : ToolboxView

@property (strong, nonatomic) Moobee* moobee;
@property (strong, nonatomic) TmdbMovie* tmdbMovie;

@end
