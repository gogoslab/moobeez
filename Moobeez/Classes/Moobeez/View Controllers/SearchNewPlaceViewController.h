//
//  SearchNewPlaceViewController.h
//  Moobeez
//
//  Created by Radu Banea on 11/08/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "PlacePickerViewController.h"

@class TmdbTV;

typedef void (^SelectPlaceHandler) (id place);

@interface SearchNewPlaceViewController : PlacePickerViewController

@property (copy, nonatomic) SelectPlaceHandler selectHandler;

@end
