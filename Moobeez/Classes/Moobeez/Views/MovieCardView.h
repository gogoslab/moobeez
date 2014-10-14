//
//  MovieCardView.h
//  Moobeez
//
//  Created by Radu Banea on 13/10/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Moobee;

@interface MovieCardView : UIView

@property (weak, nonatomic) Moobee* movie;

@property (strong, nonatomic) IBOutlet UIVisualEffectView *rightCoverView;
@property (strong, nonatomic) IBOutlet UIVisualEffectView *leftCoverView;

@end
