//
//  TimelineSectionCell.h
//  Moobeez
//
//  Created by Radu Banea on 12/08/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimelineSectionCell : UITableViewCell

@property (strong, nonatomic) NSMutableArray* items;
@property (strong, nonatomic) NSDate* date;

@end
