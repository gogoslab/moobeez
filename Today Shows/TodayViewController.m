//
//  TodayViewController.m
//  Today Shows
//
//  Created by Radu Banea on 06/06/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "TodayViewController.h"
#import "TvShowCell.h"
#import "BasicDatabase.h"
#import "NSDate+Calculator.h"
#import <NotificationCenter/NotificationCenter.h>

@interface TodayViewController () <NCWidgetProviding, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray* items;

@property (strong, nonatomic) BasicDatabase* database;
@property (strong, nonatomic) NSMutableDictionary* imagesSettings;

@property (weak, nonatomic) IBOutlet UILabel *noTvShowsLabel;
@end

@implementation TodayViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.database = [[BasicDatabase alloc] initWithPath:DATABASE_PATH placeholderPath:nil];
    self.imagesSettings = [[NSMutableDictionary alloc] initWithContentsOfFile:[GROUP_PATH stringByAppendingPathComponent:@"ImagesSettings.plist"]];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TvShowCell" bundle:nil] forCellReuseIdentifier:@"TvShowCell"];
    [self reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encoutered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}

- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets {
    return UIEdgeInsetsZero;
}

- (void)reloadData {
    
    self.items = [self.database executeQuery:[self query]];
    
    if (self.items.count) {
        for (NSMutableDictionary* item in self.items) {
            item[@"posterPath"] = [self.imagesSettings[@"secure_base_url"] stringByAppendingString:[NSString stringWithFormat:@"w%ld%@", (long)92, item[@"posterPath"]]];
        }

        self.tableView.hidden = NO;
        self.noTvShowsLabel.hidden = YES;
        
        [self.tableView reloadData];
        self.preferredContentSize = self.tableView.contentSize;
    }
    else {

        self.tableView.hidden = YES;
        self.noTvShowsLabel.hidden = NO;
        
        [self.tableView reloadData];
        self.preferredContentSize = CGSizeMake(self.view.frame.size.width, 40);

    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TvShowCell* cell = [tableView dequeueReusableCellWithIdentifier:@"TvShowCell"];
    
    cell.tvShowDictionary = self.items[indexPath.row];
    
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (NSString*)query {
    
    NSTimeInterval beginDate = [[[NSDate date] resetToMidnight] timeIntervalSince1970];
    NSTimeInterval endDate = [[[NSDate date] resetToLateMidnight] timeIntervalSince1970];
    
   return [NSString stringWithFormat:@"SELECT Teebeez.name, Teebeez.posterPath, Episodes.seasonNumber, Episodes.episodeNumber FROM Teebeez JOIN Episodes ON (Teebeez.ID = Episodes.teebeeId) WHERE (Episodes.airDate <> '(null)' AND Episodes.airDate >= '%f' AND Episodes.airDate <= '%f' AND watched = '0') ORDER BY Episodes.airDate LIMIT 9", beginDate, endDate];
}

@end
