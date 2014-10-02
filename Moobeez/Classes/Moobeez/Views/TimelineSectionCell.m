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

@end

@implementation TimelineSectionCell

- (void)awakeFromNib {
    // Initialization code
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TimelineMovieCell" bundle:nil] forCellReuseIdentifier:@"MovieCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"TimelineWatchlistCell" bundle:nil] forCellReuseIdentifier:@"WatchlistCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"TimelineTVCell" bundle:nil] forCellReuseIdentifier:@"TVCell"];
}

- (void)setItems:(NSMutableArray *)items {
    
    _items = items;

    
    [self.tableView reloadData];
    
    self.tableView.height = self.tableView.contentSize.height;
    
    UIImageView* imageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"timeline_section_mask.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(40.0, 40.0, 40.0, 40.0) resizingMode:UIImageResizingModeStretch]];
    imageView.frame = self.tableView.bounds;
    
    self.tableView.maskView = imageView;

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
    
    TimelineItem* item = self.items[indexPath.row];
    
    TimelineItemCell* cell = [tableView dequeueReusableCellWithIdentifier:(item.isMovie ? (item.rating >= 0 ? @"MovieCell" : @"WatchlistCell") : @"TVCell")];
    
    cell.width = tableView.width;
    cell.item = item;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.parentTableView.delegate tableView:self.parentTableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:[self.parentTableView indexPathForCell:self].section]];
}

+ (CGFloat)heightForItems:(NSMutableArray*)items {
    return 140 * items.count + 20;
}

@end
