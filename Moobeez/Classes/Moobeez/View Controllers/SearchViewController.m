//
//  SearchViewController.m
//  Moobeez
//
//  Created by Radu Banea on 09/05/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "SearchViewController.h"
#import "Moobeez.h"
#import "SearchCategoryController.h"

@interface SearchViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray* searchControllers;

@property (readonly, nonatomic) SearchCategoryController* selectedController;

@property (weak, nonatomic) IBOutlet UILabel *noResultsLabel;
@end

@implementation SearchViewController

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
    
    self.searchControllers = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < self.segmentedControl.numberOfSegments; ++i) {
        SearchCategoryController* controller = [[SearchCategoryController alloc] init];
        controller.type = i;
        controller.parentViewController = self;
        [self.searchControllers addObject:controller];
    }
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SearchResultCell" bundle:nil] forCellReuseIdentifier:@"SearchResultCell"];
    
    [self performSearch];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
    cancelButton.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = cancelButton;
    
    self.searchBar.showsCancelButton = NO;
    self.searchBar.width = self.view.width - 81;
    self.searchBar.x = 8;
    
    self.searchBar.frame = [self.navigationController.navigationBar convertRect:self.searchBar.frame fromView:self.searchBar.superview];
    [self.navigationController.navigationBar addSubview:self.searchBar];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationItem.rightBarButtonItem = nil;
    
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (IBAction)cancelButtonPressed:(id)sender {
    [self.searchBar.delegate searchBarCancelButtonClicked:self.searchBar];
}

- (IBAction)segmentedControlValueChanged:(id)sender {
    
    self.noResultsLabel.hidden = self.selectedController.results.count > 0;
    [self.tableView reloadData];
    self.tableView.contentOffset = CGPointZero;
}

- (SearchCategoryController*)selectedController {
    return self.searchControllers[self.segmentedControl.selectedSegmentIndex];
}

- (void)reloadSearchType:(SearchConnectionType)type {
    if (self.segmentedControl.selectedSegmentIndex == type) {
        [self.tableView reloadData];
        self.noResultsLabel.hidden = self.selectedController.results.count > 0;
        [self.activityIndicator stopAnimating];
    }
}

- (void)performSearch {
    for (SearchCategoryController* controller in self.searchControllers) {
        [controller reloadData:YES];
    }
    [self.activityIndicator startAnimating];
    [self.tableView reloadData];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return ((section == self.segmentedControl.selectedSegmentIndex) ? self.selectedController.results.count : 0);
    
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case SearchTypeMovie:
        {
            SearchResultCell* cell = [tableView dequeueReusableCellWithIdentifier:@"SearchResultCell"];
            cell.tmdbMovie = self.selectedController.results[indexPath.row];
            return cell;
        }
            break;
        case SearchTypeTvShow:
        {
            SearchResultCell* cell = [tableView dequeueReusableCellWithIdentifier:@"SearchResultCell"];
            cell.tmdbTv = self.selectedController.results[indexPath.row];
            return cell;
        }
            break;
        case SearchTypePeople:
        {
            SearchResultCell* cell = [tableView dequeueReusableCellWithIdentifier:@"SearchResultCell"];
            cell.tmdbPerson = self.selectedController.results[indexPath.row];
            return cell;
        }
            break;
            
        default:
            break;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case SearchTypeMovie:
        {
            TmdbMovie* movie = [self.searchControllers[indexPath.section] results][indexPath.row];
            
            self.view.userInteractionEnabled = NO;
            MovieConnection* connection = [[MovieConnection alloc] initWithTmdbId:movie.id completionHandler:^(WebserviceResultCode code, TmdbMovie *movie) {
                if (code == WebserviceResultOk) {
                    Moobee* moobee = [Moobee moobeeWithTmdbMovie:movie];
                    
                    if (moobee.id == -1) {
                        moobee.type = MoobeeNoneType;
                    }
                    
                    MovieViewController* viewController = [[MovieViewController alloc] initWithNibName:@"MovieViewController" bundle:nil];
                    viewController.moobee = moobee;
                    viewController.tmdbMovie = movie;
                    
                    [self presentViewController:viewController animated:NO completion:^{}];
                }
                self.view.userInteractionEnabled = YES;
            }];
            [self startConnection:connection];
        }
            break;
        case SearchTypeTvShow:
        {
            TmdbTV* tv = [self.searchControllers[indexPath.section] results][indexPath.row];
            
            self.view.userInteractionEnabled = NO;
            TvConnection* connection = [[TvConnection alloc] initWithTmdbId:tv.id completionHandler:^(WebserviceResultCode code, TmdbTV* tv) {
                if (code == WebserviceResultOk) {
                    Teebee* teebee = [Teebee teebeeWithTmdbTV:tv];
                    
                    TvViewController* viewController = [[TvViewController alloc] initWithNibName:@"TvViewController" bundle:nil];
                    viewController.teebee = teebee;
                    viewController.tmdbTv = tv;
                    [self presentViewController:viewController animated:NO completion:^{}];
                }
                self.view.userInteractionEnabled = YES;
            }];
            [self startConnection:connection];
        }
            break;
        case SearchTypePeople:
        {
            TmdbPerson* person = [self.searchControllers[indexPath.section] results][indexPath.row];
            
            PersonConnection* connection = [[PersonConnection alloc] initWithTmdbId:person.id completionHandler:^(WebserviceResultCode code, TmdbPerson *person) {
                if (code == WebserviceResultOk) {
                    ActorViewController* viewController = [[ActorViewController alloc] initWithNibName:@"ActorViewController" bundle:nil];
                    viewController.tmdbActor = person;
                    [self presentViewController:viewController animated:NO completion:^{}];
                }
            }];
            
            [self.connectionsManager startConnection:connection];
        }
            break;
            
        default:
            break;
    }
    
}

@end

