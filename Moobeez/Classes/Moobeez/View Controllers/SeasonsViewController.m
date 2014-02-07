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

@end

@implementation SeasonsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SeasonCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SeasonCell"];
    
    cell.numberOfEpisodesWatched = self.teebee.seasons[StringId([self.tv.seasons[indexPath.section] seasonNumber])];
    cell.season = self.tv.seasons[indexPath.section];
    cell.teebee = self.teebee;
    
    return cell;
}


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.
    EpisodesViewController *viewController = [[EpisodesViewController alloc] initWithNibName:@"EpisodesViewController" bundle:nil];

    // Pass the selected object to the new view controller.
    
    viewController.teebee = self.teebee;
    viewController.season = self.tv.seasons[indexPath.section];
    
    // Push the view controller.
    [self.navigationController pushViewController:viewController animated:YES];
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

@end
