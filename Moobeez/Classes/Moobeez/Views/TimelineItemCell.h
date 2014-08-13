//
//  TimelineItemCell.h
//  Moobeez
//
//  Created by Radu Banea on 12/08/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TimelineItem;

@interface TimelineItemCell : UITableViewCell

@property (strong, nonatomic) TimelineItem* item;

@end
