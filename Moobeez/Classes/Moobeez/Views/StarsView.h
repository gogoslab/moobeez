//
//  StarsView.h
//  Moobeez
//
//  Created by Radu Banea on 10/23/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"


@interface StarsView : UIView

@property (readwrite, nonatomic) CGFloat rating;
@property (readwrite, nonatomic) CGFloat ratingInPixels;

@property (copy, nonatomic) EmptyHandler updateHandler;

@end
