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

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UILabel *seasonLabel;
@end

@implementation EpisodesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"EpisodeCell" bundle:nil] forCellReuseIdentifier:@"EpisodeCell"];
    
    self.seasonLabel.text = self.season.name;

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
    cell.teebeeEpisode = self.teebee.episodes[StringId(self.season.seasonNumber)][StringId(cell.episode.episodeNumber)];
    cell.teebee = self.teebee;
    
    return cell;
}

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
