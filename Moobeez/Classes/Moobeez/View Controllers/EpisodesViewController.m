//
//  EpisodesViewController.m
//  Moobeez
//
//  Created by Radu Banea on 06/02/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "EpisodesViewController.h"
#import "Moobeez.h"

@interface EpisodesViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation EpisodesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"EpisodeCell" bundle:nil] forCellReuseIdentifier:@"EpisodeCell"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:DidUpdateWatchedEpisodesNotification object:self.teebee];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.season.episodes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EpisodeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EpisodeCell"];
    
    cell.episode = self.season.episodes[indexPath.row];
    cell.teebeeEpisode = self.teebee.episodes[StringInteger(self.season.seasonNumber)][StringInteger((long)cell.episode.episodeNumber)];
    cell.teebee = self.teebee;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TmdbTvEpisode* tmdbEpisode = self.season.episodes[indexPath.row];
    TeebeeEpisode* episode = self.teebee.episodes[StringInteger(self.season.seasonNumber)][StringInteger((long)tmdbEpisode.episodeNumber)];
    
    if (!self.allEpisodes && episode.watched) {
        return 0.0;
    }
    
    return tableView.rowHeight;
    
}

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)reloadData {

    [[Database sharedDatabase] pullEpisodesForTeebee:self.teebee inSeason:self.season.seasonNumber];
    [self.tableView reloadData];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DidUpdateWatchedEpisodesNotification object:self.teebee];
}
@end
