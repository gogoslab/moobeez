//
//  SearchNewTvViewController.h
//  Moobeez
//
//  Created by Radu Banea on 02/01/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "ViewController.h"

@class TmdbTV;

typedef void (^SelectTvHandler) (TmdbTV* tv);

@interface SearchNewTvViewController : ViewController

@property (copy, nonatomic) SelectTvHandler selectHandler;

@end
