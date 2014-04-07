//
//  SeasonsViewController.m
//  Moobeez
//
//  Created by Radu Banea on 06/02/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "SeasonsViewController.h"
#import "Moobeez.h"

@interface SeasonsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) EpisodesViewController* episodesViewController;
@property (strong, nonatomic) UITableViewCell* episodesCell;

@property (readwrite, nonatomic) NSInteger selectedSection;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@end

@implementation SeasonsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _selectedSection = -1;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SeasonCell" bundle:nil] forCellReuseIdentifier:@"SeasonCell"];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Ret`urn the number of sections.
    return self.tv.seasons.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return (self.selectedSection == section ? 2 : 1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        SeasonCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SeasonCell"];
        
        cell.allEpisodes = (self.segmentedControl.selectedSegmentIndex == 1);
        cell.numberOfEpisodesWatched = self.teebee.seasons[StringInteger([self.tv.seasons[indexPath.section] seasonNumber])];
        cell.season = self.tv.seasons[indexPath.section];
        cell.teebee = self.teebee;
        
        return cell;
    }
    else {
        return self.episodesCell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger rowHeight = 70;
    
    if (indexPath.row == 0) {
        BOOL hasNotWatchedEpisodes = ([self.teebee.seasons[StringInteger([self.tv.seasons[indexPath.section] seasonNumber])] intValue] < [self.tv.seasons[indexPath.section] episodes].count);
        
        if (self.segmentedControl.selectedSegmentIndex == 0 && !hasNotWatchedEpisodes) {
            return 0.0;
        }

        return rowHeight;
    }
    else {
        return tableView.height - rowHeight;
    }
}


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == self.selectedSection) {
        [self setSelectedSection:-1 animated:YES];
    }
    else {
        [self setSelectedSection:indexPath.section animated:YES];
    }
}

- (IBAction)segmentedControlValueChanged:(id)sender {
    
    _selectedSection = -1;
    self.tableView.scrollEnabled = YES;
    
    [self.tableView reloadData];
    
    self.episodesViewController.allEpisodes = (self.segmentedControl.selectedSegmentIndex == 1);

    self.tableView.contentOffset = CGPointZero;
}

- (void)reloadData {
    
    if (!self.teebee.seasons) {
        [[Database sharedDatabase] pullSeasonsForTeebee:self.teebee];
    }

    [self.tableView reloadData];

    if (self.tv.seasons.count && ![self.tv.seasons[0] episodes]) {
        
        for (TmdbTvSeason* emptySeason in self.tv.seasons) {
            
            TvSeasonConnection* connection = [[TvSeasonConnection alloc] initWithTmdbId:self.tv.id seasonNumber:emptySeason.seasonNumber completionHandler:^(WebserviceResultCode code, TmdbTvSeason *season) {
               
                if (code == WebserviceResultOk ) {
                    
                    [self.tv.seasons replaceObjectAtIndex:[self.tv.seasons indexOfObject:emptySeason] withObject:season];
                    [self.tableView reloadData];
                    
                }
                
            }];
            
            connection.activityIndicator = ((SeasonCell*) [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[self.tv.seasons indexOfObject:emptySeason]]]).activityIndicator;
            [self.connectionsManager startConnection:connection];
        }
    }
}

- (UITableViewCell*)episodesCell {
    
    if (!_episodesCell) {
        _episodesCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EpisodesCell"];
        _episodesCell.backgroundColor = [UIColor clearColor];
        _episodesCell.frame = CGRectMake(0, 0, self.tableView.width, self.tableView.height - 70);
        
        self.episodesViewController.view.frame = _episodesCell.bounds;
        [_episodesCell addSubview:self.episodesViewController.view];

    }
    
    return _episodesCell;
}

- (EpisodesViewController*)episodesViewController {
    
    if (!_episodesViewController) {
        _episodesViewController = [[EpisodesViewController alloc] initWithNibName:@"EpisodesViewController" bundle:nil];
        _episodesViewController.teebee = self.teebee;
    }
    
    return _episodesViewController;
}

- (void)setSelectedSection:(NSInteger)selectedSection {
    [self setSelectedSection:selectedSection animated:NO];
}

- (void)setSelectedSection:(NSInteger)selectedSection animated:(BOOL)animated {
    
    if (selectedSection == _selectedSection) {
        return;
    }
    
    if (selectedSection == -1) {

        if (!animated) {
            [self.tableView reloadData];
        }
        else {
            [self.tableView beginUpdates];
            
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:_selectedSection]] withRowAnimation:UITableViewRowAnimationFade];
            _selectedSection = selectedSection;
            
            [self.tableView endUpdates];
        }
        
        self.tableView.scrollEnabled = YES;
    }
    else {
        _selectedSection = selectedSection;

        self.episodesViewController.season = self.tv.seasons[selectedSection];
        [[Database sharedDatabase] pullEpisodesForTeebee:self.teebee inSeason:self.episodesViewController.season.seasonNumber];
        [self.episodesViewController.tableView reloadData];
        self.episodesViewController.tableView.contentOffset = CGPointZero;
        
        if (!animated) {
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:selectedSection]] withRowAnimation:UITableViewRowAnimationFade];
        }
        else {
            [self.tableView reloadData];
        }
        
        self.tableView.scrollEnabled = NO;
        
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:selectedSection] atScrollPosition:UITableViewScrollPositionTop animated:animated];
    }
    
}

@end
