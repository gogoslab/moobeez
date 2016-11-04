//
//  DashboardViewController.m
//  Moobeez
//
//  Created by Radu Banea on 09/05/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "DashboardViewController.h"
#import "Moobeez.h"

typedef enum : NSUInteger {
    
    SectionTodayShows,
    SectionMissedShows,

    SectionWatchlistMovies,

    SectionsCount
    
} SectionType;

@interface DashboardViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property (strong, nonatomic) NSMutableArray* todayShows;
@property (strong, nonatomic) NSMutableArray* missedShows;

@property (strong, nonatomic) NSMutableArray* wathclistMovies;

@property (strong, nonatomic) NSMutableDictionary* imagesSettings;

@end

@implementation DashboardViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.imagesSettings = [[NSMutableDictionary alloc] initWithContentsOfFile:[GROUP_PATH stringByAppendingPathComponent:@"ImagesSettings.plist"]];

    [self.tableView registerNib:[UINib nibWithNibName:@"DashboardHeaderCell" bundle:nil] forCellReuseIdentifier:@"DashboardHeaderCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"DashboardFooterCell" bundle:nil] forCellReuseIdentifier:@"DashboardFooterCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"DashboardTvShowCell" bundle:nil] forCellReuseIdentifier:@"DashboardTvShowCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"DashboardMovieCell" bundle:nil] forCellReuseIdentifier:@"DashboardMovieCell"];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"check_in_icon_big.png"] style:UIBarButtonItemStylePlain target:self action:@selector(checkinButtonPressed:)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self loadTodayShows];
    [self loadMissedShows];
    [self loadWatchlistMovies];
    
    [self.tableView reloadData];
    
}

#pragma mark - Load sections

- (void)loadTodayShows {
    
    NSTimeInterval beginDate = [[[NSDate dateWithTimeIntervalSinceNow:- 24 * 3600] resetToMidnight] timeIntervalSince1970];
    NSTimeInterval endDate = [[[NSDate dateWithTimeIntervalSinceNow:- 24 * 3600] resetToLateMidnight] timeIntervalSince1970];
    
    NSString* query = [NSString stringWithFormat:@"SELECT Teebeez.name, Teebeez.posterPath, Episodes.teebeeId, Episodes.seasonNumber, Episodes.episodeNumber FROM Teebeez JOIN Episodes ON (Teebeez.ID = Episodes.teebeeId) WHERE (Episodes.airDate <> '(null)' AND Episodes.airDate >= '%f' AND Episodes.airDate <= '%f' AND watched = '0') ORDER BY Episodes.airDate", beginDate, endDate];
    
    self.todayShows = [[Database sharedDatabase] executeQuery:query];
    
}

- (void)loadMissedShows {
    
    NSTimeInterval endDate = [[[NSDate dateWithTimeIntervalSinceNow:- 24 * 3600] resetToLateMidnight] timeIntervalSince1970];
    
    NSString* query = [NSString stringWithFormat:@"SELECT Teebeez.name, Teebeez.posterPath, Episodes.teebeeId, Episodes.seasonNumber, Episodes.episodeNumber FROM Teebeez JOIN Episodes ON (Teebeez.ID = Episodes.teebeeId) WHERE (Episodes.airDate <> '(null)' AND Episodes.airDate <= '%f' AND watched = '0') ORDER BY Episodes.airDate", endDate];
    
    self.missedShows = [[Database sharedDatabase] executeQuery:query];
    
}

- (void)loadWatchlistMovies {
    
    self.wathclistMovies = [[Database sharedDatabase] moobeezWithType:MoobeeOnWatchlistType];
    
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return SectionsCount;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSMutableArray* items = nil;
    
    switch (section) {
        case SectionTodayShows:
            items = self.todayShows;
            break;
        case SectionMissedShows:
            items = self.missedShows;
            break;
        case SectionWatchlistMovies:
            items = self.wathclistMovies;
            break;
            
        default:
            break;
    }
    
    if (items.count) {
        return items.count + 2;
    }
    
    return 0;
    
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        DashboardHeaderCell* cell = [tableView dequeueReusableCellWithIdentifier:@"DashboardHeaderCell"];

        NSString* title = @"";
        
        switch (indexPath.section) {
            case SectionTodayShows:
                title = @"Today Shows";
                break;
            case SectionMissedShows:
                title = @"Missed Shows";
                break;
            case SectionWatchlistMovies:
                title = @"Watchlist";
                break;
            default:
                break;
        }
        cell.titleLabel.text = [title uppercaseString];
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }
    
    NSInteger numberOfRows = [self tableView:tableView numberOfRowsInSection:indexPath.section];
    
    if (indexPath.row == numberOfRows - 1) {
        
        DashboardFooterCell* cell = [tableView dequeueReusableCellWithIdentifier:@"DashboardFooterCell"];
        cell.backgroundColor = [UIColor clearColor];

        return cell;
    }
    
    NSInteger index = indexPath.row - 1;
    
    switch (indexPath.section) {
        case SectionTodayShows:
        {
            DashboardTvShowCell* cell = [tableView dequeueReusableCellWithIdentifier:@"DashboardTvShowCell"];
            
            cell.tvShowDictionary = self.todayShows[index];
            
            cell.parentTableView = tableView;
            
            cell.backgroundColor = [UIColor clearColor];
            return cell;

        }
            break;
        case SectionMissedShows:
        {
            DashboardTvShowCell* cell = [tableView dequeueReusableCellWithIdentifier:@"DashboardTvShowCell"];
            
            cell.tvShowDictionary = self.missedShows[index];
            
            cell.parentTableView = tableView;
            
            cell.backgroundColor = [UIColor clearColor];
            return cell;
            
        }
            break;
            
        case SectionWatchlistMovies:
        {
            DashboardMovieCell* cell = [tableView dequeueReusableCellWithIdentifier:@"DashboardMovieCell"];
            
            cell.moobee = self.wathclistMovies[index];
            
            cell.parentTableView = tableView;
            
            cell.backgroundColor = [UIColor clearColor];
            return cell;
            
        }
            break;

        default:
            break;
    }
    
    return nil;

    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSInteger numberOfRows = [self tableView:tableView numberOfRowsInSection:indexPath.section];
    
    if (indexPath.row == 0) {
        return 50;
    }
    
    if (indexPath.row == numberOfRows - 1) {
        return 20;
    }
    
    return 60;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {

    NSMutableArray* tvShowsItems = nil;
    
    switch (indexPath.section) {
        case SectionTodayShows:
            tvShowsItems = self.todayShows;
            break;
        case SectionMissedShows:
            tvShowsItems = self.missedShows;
            break;
            
        default:
            break;
    }

    if (tvShowsItems) {
        
        NSMutableDictionary* tvShowDictionary = tvShowsItems[indexPath.row - 1];
        
        NSString* query = [NSString stringWithFormat:@"UPDATE Episodes SET watched = '1' WHERE teebeeId = '%@' AND seasonNumber = '%@' AND episodeNumber = '%@'", tvShowDictionary[@"teebeeId"], tvShowDictionary[@"seasonNumber"], tvShowDictionary[@"episodeNumber"]];
        
        NSLog(@"query: %@", query);
        
        if ([[Database sharedDatabase] executeQuery:query]) {
            [tvShowsItems removeObjectAtIndex:indexPath.row - 1];

            if (tvShowsItems.count) {
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
            }
            else {
                [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:indexPath.section], [NSIndexPath indexPathForRow:1 inSection:indexPath.section], [NSIndexPath indexPathForRow:2 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationTop];
            }
        }
    }
    else {
        
        Moobee* moobee = self.wathclistMovies[indexPath.row - 1];
        
        DashboardMovieCell* cell = (DashboardMovieCell*) [tableView cellForRowAtIndexPath:indexPath];
        cell.watchedButton.hidden = YES;
        [cell.activityIndicator startAnimating];
        
        MovieConnection* connection = [[MovieConnection alloc] initWithTmdbId:moobee.tmdbId completionHandler:^(WebserviceResultCode code, TmdbMovie *movie) {
            
            if (code == WebserviceResultOk) {
                [self goToMovieDetailsScreenForMoobee:moobee andMovie:movie];
            }
            
            cell.watchedButton.hidden = NO;
            [cell.activityIndicator stopAnimating];

        }];
        
        [self startConnection:connection];
    }
    
}

- (void)goToMovieDetailsScreenForMoobee:(Moobee*)moobee andMovie:(TmdbMovie*)movie {
    
    MovieViewController* viewController = [[MovieViewController alloc] initWithNibName:@"MovieViewController" bundle:nil];
    viewController.moobee = moobee;
    viewController.tmdbMovie = movie;
    
    [self.navigationController pushViewController:viewController animated:NO];
    
    viewController.closeHandler = ^{
        
    };
    
}

- (IBAction)checkinButtonPressed:(id)sender {
    
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Movie", @"TV Show", nil];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 0:
            [self.appDelegate.sideTabController presentCheckInViewControllerAnimated:YES];
            break;
        case 1:
            [self.appDelegate.sideTabController presentCheckInTvShowViewControllerAnimated:YES];
            break;
            
        default:
            break;
    }
    
}

@end
