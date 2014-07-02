//
//  DashboardMovieCell.h
//  Moobeez
//
//  Created by Radu Banea on 02/07/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Moobee;

@interface DashboardMovieCell : UITableViewCell

@property (strong, nonatomic) Moobee* moobee;

@property (weak, nonatomic) UITableView* parentTableView;

@end
