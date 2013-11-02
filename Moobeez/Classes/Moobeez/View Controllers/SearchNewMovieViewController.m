//
//  SearchNewMovieViewController.m
//  Moobeez
//
//  Created by Radu Banea on 01/11/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "SearchNewMovieViewController.h"
#import "Moobeez.h"

@interface SearchNewMovieViewController () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet AMBlurView *blurView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) NSMutableArray* movies;
@end

@implementation SearchNewMovieViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.contentView.layer.cornerRadius = 4;
    [self.tableView registerNib:[UINib nibWithNibName:@"SearchResultCell" bundle:nil] forCellReuseIdentifier:@"SearchResultCell"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.movies.count == 0) {
        [self.searchBar becomeFirstResponder];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonPressed:(id)sender {
    [self.view removeFromSuperview];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = NO;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [searchBar resignFirstResponder];

    SearchMovieConnection* connection = [[SearchMovieConnection alloc] initWithQuery:searchBar.text completionHandler:^(WebserviceResultCode code, NSMutableArray *movies) {
        self.movies = movies;
        [self reloadData];
    }];
    
    [self startConnection:connection];
    
}

- (void)reloadData {
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.movies.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    SearchResultCell* cell = [tableView dequeueReusableCellWithIdentifier:@"SearchResultCell"];
    
    cell.tmdbMovie = self.movies[indexPath.row];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    self.selectHandler(self.movies[indexPath.row]);
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
