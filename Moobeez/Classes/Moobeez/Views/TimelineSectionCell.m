//
//  TimelineSectionCell.m
//  Moobeez
//
//  Created by Radu Banea on 12/08/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "TimelineSectionCell.h"
#import "Moobeez.h"

@interface TimelineSectionCell () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UILabel *monthLabel;

@property (strong, nonatomic) CALayer* maskLayer;

@end

@implementation TimelineSectionCell

- (void)awakeFromNib {
    // Initialization code
    
    UIImage* maskImage = [[UIImage imageNamed:@"timeline_section_mask.png"] imageWithAlignmentRectInsets:UIEdgeInsetsMake(0.5, 0.0, 0.3, 1.0)];
    
    self.maskLayer = [CALayer layer];
    self.maskLayer.contents = (id) maskImage.CGImage;
    self.maskLayer.frame = self.tableView.bounds;
    self.tableView.layer.mask = self.maskLayer;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TimelineItemCell" bundle:nil] forCellReuseIdentifier:@"Cell"];
}

- (void)setItems:(NSMutableArray *)items {
    
    _items = items;
    
    [self.tableView reloadData];
    self.tableView.height = self.tableView.contentSize.height;
    self.maskLayer.frame = self.tableView.bounds;

    self.date = ((TimelineItem*) self.items.lastObject).date;
    
}

- (void)setDate:(NSDate *)date {
    
    _date = date;
    
    self.dayLabel.text = [[NSDateFormatter dateFormatterWithFormat:@"d"] stringFromDate:date];
    self.monthLabel.text = [[NSDateFormatter dateFormatterWithFormat:@"MMM"] stringFromDate:date];
    
}

#pragma mark - Table 

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TimelineItemCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    cell.item = self.items[indexPath.row];
    
    return cell;
}

@end
