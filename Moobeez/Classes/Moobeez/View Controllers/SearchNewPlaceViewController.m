//
//  SearchNewPlaceViewController.m
//  Moobeez
//
//  Created by Radu Banea on 11/08/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "SearchNewPlaceViewController.h"
#import "Moobeez.h"

@interface SearchNewPlaceViewController () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet SideTabSearchBar *searchBar;

@end

@implementation SearchNewPlaceViewController

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
    [self.placesTableView registerNib:[UINib nibWithNibName:@"NewPlaceCell" bundle:nil] forCellReuseIdentifier:@"CheckInPlaceCell"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.data.count == 0) {
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

    self.searchText = searchBar.text;
    
    self.data = nil;
    [self.placesTableView reloadData];
    [self.placesActivityIndicator startAnimating];
    
    [self refresh];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CheckInPlaceCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CheckInPlaceCell"];
    
    NSDictionary* place = self.data[indexPath.row];
    
    cell.nameLabel.text = place[@"name"];
    
    NSString *category = place[@"category"];
    NSNumber *wereHereCount = place[@"were_here_count"];
    
    NSString* subtitle = @"";
    
    if (wereHereCount) {
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        NSString *wereHere = [numberFormatter stringFromNumber:wereHereCount];
        
        if (category) {
            subtitle = [NSString stringWithFormat:@"%@ • %@ were here", [category capitalizedString], wereHere];
        }
        subtitle = [NSString stringWithFormat:@"%@ were here", wereHere];
    }
    if (category) {
        subtitle = [category capitalizedString];
    }
    
    cell.detailsLabel.text = subtitle;
    
    [cell.iconView loadImageWithPath:place[@"picture"][@"data"][@"url"] completion:^(BOOL didLoadImage) {}];
    
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    self.selectHandler(self.data[indexPath.row]);
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
