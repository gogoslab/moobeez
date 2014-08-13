//
//  TimelineViewController.m
//  Moobeez
//
//  Created by Radu Banea on 12/08/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "TimelineViewController.h"
#import "Moobeez.h"

@interface TimelineViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableDictionary* sections;
@property (strong, nonatomic) NSMutableArray* dates;

@end

@implementation TimelineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TimelineSectionCell" bundle:nil] forCellReuseIdentifier:@"Cell"];
    
    self.sections = [[NSMutableDictionary alloc] init];
}

- (void)loadData {
    
    NSMutableArray* timelineItems = [[Database sharedDatabase] timelineItemsFromDate:[NSDate date] toDate:nil];
    
    for (TimelineItem* item in timelineItems) {
        
        NSString* key = [[NSDateFormatter dateFormatterWithFormat:@"yyyyMMdd"] stringFromDate:item.date];
        
        if (!self.sections[key]) {
            self.sections[key] = [[NSMutableArray alloc] init];
        }
        
        [self.sections[key] addObject:item];
        
    }
    
    self.dates = [[NSMutableArray alloc] initWithArray:self.sections.allKeys];
    [self.dates sortedArrayUsingSelector:@selector(compare:)];
    
    [self.tableView reloadData];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dates.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TimelineSectionCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    cell.items = self.sections[self.dates[indexPath.section]];
    
    return cell;

}

@end
