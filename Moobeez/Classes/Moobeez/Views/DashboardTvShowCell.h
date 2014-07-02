//
//  DashboardTvShowCell.h
//  Moobeez
//
//  Created by Radu Banea on 01/07/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DashboardTvShowCell : UITableViewCell

@property (strong, nonatomic) NSMutableDictionary* tvShowDictionary;

@property (weak, nonatomic) UITableView* parentTableView;

@end
