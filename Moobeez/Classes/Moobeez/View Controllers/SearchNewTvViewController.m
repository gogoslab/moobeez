//
//  SearchNewTvViewController.m
//  Moobeez
//
//  Created by Radu Banea on 02/01/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "SearchNewTvViewController.h"
#import "Moobeez.h"

@interface SearchNewTvViewController () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *blurView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) NSMutableArray* tvs;
@end

@implementation SearchNewTvViewController

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
    
    if (self.tvs.count == 0) {
        [self.searchBar becomeFirstResponder];
    }
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor mainColor],NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    
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

    SearchTvConnection* connection = [[SearchTvConnection alloc] initWithQuery:searchBar.text completionHandler:^(WebserviceResultCode code, NSMutableArray *tvs) {
        if (code == WebserviceResultOk) {
            self.tvs = tvs;
            [self.tvs sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                return [@(((TmdbTV*) obj2).rating) compare:@(((TmdbTV*) obj1).rating)];
            }];
            [self reloadData];
        }
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
    return self.tvs.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    SearchResultCell* cell = [tableView dequeueReusableCellWithIdentifier:@"SearchResultCell"];
    
    cell.tmdbTv = self.tvs[indexPath.row];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    self.selectHandler(self.tvs[indexPath.row]);
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)prepareBlurInView:(UIView*)view {
    
    CGSize size = self.blurView.frame.size;
    
    CGFloat scale = 1;//[UIScreen mainScreen].scale;
    size.width *= scale;
    size.height *= scale;
    
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextScaleCTM(ctx, scale, scale);
    
    [view.layer renderInContext:ctx];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    GPUImageiOSBlurFilter *filter = [[GPUImageiOSBlurFilter alloc] init];
    filter.blurRadiusInPixels = [UIScreen mainScreen].scale * 4;
    self.blurView.image = [filter imageByFilteringImage:image];
    
    self.blurView.contentMode = UIViewContentModeBottom;
    
}

@end
