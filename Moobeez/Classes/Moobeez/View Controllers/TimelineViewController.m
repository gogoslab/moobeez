//
//  TimelineViewController.m
//  Moobeez
//
//  Created by Radu Banea on 12/08/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "TimelineViewController.h"
#import "Moobeez.h"

#define DELAY_BETWEEN_LOADING 0.1

@interface TimelineViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableDictionary* sections;
@property (strong, nonatomic) NSMutableArray* dates;

@property (strong, nonatomic) NSMutableArray* itemsToLoad;
@property (strong, nonatomic) NSDate* lastPreviousDate;

@property (readwrite, nonatomic) BOOL canLoadPrevious;
@property (readwrite, nonatomic) BOOL shouldLoadPrevious;
@property (strong, nonatomic) IBOutlet UITableViewCell *loadingCell;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingActivityIndicator;

@end

@implementation TimelineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TimelineSectionCell" bundle:nil] forCellReuseIdentifier:@"Cell"];
    
    [self startCleanLoading];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(databaseDidChanged) name:MoobeezDidReloadNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(databaseDidChanged) name:TeebeezDidReloadNotification object:nil];
}

- (void)databaseDidChanged {

    self.sections = [[NSMutableDictionary alloc] init];
    
    self.canLoadPrevious = YES;
    

    NSMutableArray* futureItems = [[Database sharedDatabase] timelineItemsFromDate:[NSDate date] toDate:nil];
    
    NSMutableArray* pastItems = [[Database sharedDatabase] timelineMoviesFromDate:self.lastPreviousDate toDate:[NSDate date] lastDate:nil limit:-1];

    for (TimelineItem* item in futureItems) {
        [self addItem:item reload:NO];
    }
    
    for (TimelineItem* item in pastItems) {
        [self addItem:item reload:NO];
    }
    
    self.dates = [[NSMutableArray alloc] initWithArray:self.sections.allKeys];
    [self.dates sortUsingSelector:@selector(compare:)];

    [self.tableView reloadData];
    
}

- (void)startCleanLoading {

    self.sections = [[NSMutableDictionary alloc] init];
    
    self.lastPreviousDate = [NSDate date];
    self.canLoadPrevious = YES;
    
    [self loadFuturePage];

}

- (void)loadFuturePage {

    self.itemsToLoad = [[Database sharedDatabase] timelineItemsFromDate:[NSDate date] toDate:nil];
    
    [self.itemsToLoad sortUsingSelector:@selector(compareByDate:)];

    [self performSelector:@selector(loadNextItem) withObject:nil afterDelay:DELAY_BETWEEN_LOADING];
}

- (void)loadPreviousPage {
    
    NSDate* lastDate = nil;
    
    NSMutableArray* items = [[Database sharedDatabase] timelineMoviesFromDate:nil toDate:self.lastPreviousDate lastDate:&lastDate limit:3];
    self.lastPreviousDate = lastDate;
    
    [self.itemsToLoad addObjectsFromArray:items];
    
    [self performSelector:@selector(loadNextItem) withObject:nil afterDelay:DELAY_BETWEEN_LOADING];
    
    
}

- (void)loadNextItem {
    
    if (self.itemsToLoad.count == 0) {
        return;
    }
    
    NSInteger index = 0;
    
    TimelineItem* item = self.itemsToLoad[index];
    
    if (item.backdropPath.length > 0) {
        [self addItem:item reload:YES];
        [self.itemsToLoad removeObjectAtIndex:index];
        [self performSelector:@selector(loadNextItem) withObject:nil afterDelay:DELAY_BETWEEN_LOADING];
    }
    else {
        
        if (item.isMovie) {
            
            MovieConnection* connection = [[MovieConnection alloc] initWithTmdbId:item.tmdbId completionHandler:^(WebserviceResultCode code, TmdbMovie *movie) {
                if (code == WebserviceResultOk) {
                    item.backdropPath = movie.backdropPath;
                    if (item.backdropPath) {
                        [[Database sharedDatabase] updateColumnValues:@[item.backdropPath] forColumn:@"backdropPath" intoTable:@"Moobeez" forIds:@[StringInteger(item.id)]];
                    }
                }
                
                [self addItem:item reload:YES];
                [self.itemsToLoad removeObjectAtIndex:index];
                [self performSelector:@selector(loadNextItem) withObject:nil afterDelay:DELAY_BETWEEN_LOADING];
            }];
            
            [self startConnection:connection];
        }
        else {
            
            TvConnection* connection = [[TvConnection alloc] initWithTmdbId:item.tmdbId completionHandler:^(WebserviceResultCode code, TmdbTV *tv) {
                if (code == WebserviceResultOk) {
                    item.backdropPath = tv.backdropPath;
                    if (item.backdropPath) {
                        [[Database sharedDatabase] updateColumnValues:@[item.backdropPath] forColumn:@"backdropPath" intoTable:@"Moobeez" forIds:@[StringInteger(item.id)]];
                    }
                }
                
                [self addItem:item reload:YES];
                [self.itemsToLoad removeObjectAtIndex:index];
                [self performSelector:@selector(loadNextItem) withObject:nil afterDelay:DELAY_BETWEEN_LOADING];
            }];
            
            [self startConnection:connection];
        }
        
    }
    
}

- (void)addItem:(TimelineItem*)item reload:(BOOL)reload {
    
    BOOL animated = NO;
    
    NSString* key = [[NSDateFormatter dateFormatterWithFormat:@"yyyyMMdd"] stringFromDate:item.date];
    
    key = [key stringByAppendingString:item.isMovie ? @"m" : @"t"];
    
    if (!self.sections[key]) {
        self.sections[key] = [[NSMutableArray alloc] init];
        animated = YES;
    }
    
    [self.sections[key] addObject:item];
    [self.sections[key] sortUsingSelector:@selector(compareByDate:)];
    
    if (!reload) {
        return;
    }
    
    self.dates = [[NSMutableArray alloc] initWithArray:self.sections.allKeys];
    [self.dates sortUsingSelector:@selector(compare:)];
    
    NSInteger index = [self.dates indexOfObject:key];

    if (index == 0 && !self.canLoadPrevious) {
        self.canLoadPrevious = YES;
        if (animated) {
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:UITableViewRowAnimationFade];
        }
        else {
            [self.tableView reloadData];
        }
    }
    else if (animated) {
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:UITableViewRowAnimationFade];
    }
    else {
        [self.tableView reloadData];
    }
    
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dates.count + (self.canLoadPrevious ? 0 : 1);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (!self.canLoadPrevious && indexPath.section == 0) {
        return self.loadingCell;
    }
    
    NSInteger section = indexPath.section;
    if (!self.canLoadPrevious) {
        section--;
    }
    
    TimelineSectionCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    cell.items = self.sections[self.dates[section]];
    cell.backgroundColor = [UIColor clearColor];
    cell.parentTableView = tableView;
    
    return cell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (!self.canLoadPrevious && indexPath.section == 0) {
        return self.loadingCell.height;
    }
    
    NSInteger section = indexPath.section;
    if (!self.canLoadPrevious) {
        section--;
    }
    
    return [TimelineSectionCell heightForItems:self.sections[self.dates[section]]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger section = indexPath.section;
    if (!self.canLoadPrevious) {
        section--;
    }
    
    TimelineItem* item = self.sections[self.dates[section]][indexPath.row];
    
    if (item.isMovie) {
        Moobee* moobee = [[Database sharedDatabase] moobeeWithTmdbId:item.tmdbId];
     
        MovieConnection* connection = [[MovieConnection alloc] initWithTmdbId:moobee.tmdbId completionHandler:^(WebserviceResultCode code, TmdbMovie *movie) {
            
            if (code == WebserviceResultOk) {
                [self goToMovieDetailsScreenForMoobee:moobee andMovie:movie];
            }
        }];
        
        [self startConnection:connection];
    }
    else {
        Teebee* teebee = [[Database sharedDatabase] teebeeWithTmdbId:item.tmdbId];
        
        TvConnection* connection = [[TvConnection alloc] initWithTmdbId:teebee.tmdbId completionHandler:^(WebserviceResultCode code, TmdbTV *tv) {
            
            if (code == WebserviceResultOk) {
                [self goToTvDetailsScreenForMoobee:teebee andTv:tv];
            }
        }];
        
        [self startConnection:connection];
    }
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView.contentOffset.y <= -self.loadingCell.height) {
        if (self.canLoadPrevious && !self.shouldLoadPrevious) {
            self.shouldLoadPrevious = YES;
        }
    }
    
    if (scrollView.contentOffset.y >= -self.loadingCell.height - 4 && self.shouldLoadPrevious) {
        self.canLoadPrevious = NO;
        self.shouldLoadPrevious = NO;
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        [self performSelector:@selector(loadPreviousPage) withObject:nil afterDelay:0.01];
    }
    
}


- (void)goToMovieDetailsScreenForMoobee:(Moobee*)moobee andMovie:(TmdbMovie*)movie {
    
    MovieViewController* viewController = [[MovieViewController alloc] initWithNibName:@"MovieViewController" bundle:nil];
    viewController.moobee = moobee;
    viewController.tmdbMovie = movie;
    
    [self presentViewController:viewController animated:NO completion:^{}];
    
    viewController.closeHandler = ^{
        
    };
    
}

- (void)goToTvDetailsScreenForMoobee:(Teebee*)teebee andTv:(TmdbTV*)tv {
    
    TvViewController* viewController = [[TvViewController alloc] initWithNibName:@"TvViewController" bundle:nil];
    viewController.teebee = teebee;
    viewController.tmdbTv = tv;
    
    [self presentViewController:viewController animated:NO completion:^{}];
    
    viewController.closeHandler = ^{
        
    };
}

@end
