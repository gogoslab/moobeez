//
//  SearchNewFriendViewController.m
//  Moobeez
//
//  Created by Radu Banea on 04/09/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "SearchNewFriendViewController.h"
#import "Moobeez.h"
#import <FacebookSDK/FacebookSDK.h>

@interface SearchNewFriendViewController () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet SideTabSearchBar *searchBar;

@property (weak, nonatomic) IBOutlet UITableView* tableView;

@property (strong, nonatomic) NSMutableArray* data;

@end

@implementation SearchNewFriendViewController

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
    [self.tableView registerNib:[UINib nibWithNibName:@"FriendCell" bundle:nil] forCellReuseIdentifier:@"FriendCell"];
    
    [self reloadFriends];
    
    if (!self.selectedFriends) {
        self.selectedFriends = [[NSMutableArray alloc] init];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor mainColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    
}

- (void)reloadFriends {

    [self.activityIndicator startAnimating];
    
    if (!FBSession.activeSession.isOpen) {
        
        [FBSession openActiveSessionWithReadPermissions:@[@"user_friends"]
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                          if (!error) {
                                              [FBSession setActiveSession:session];
                                              [self reloadFriends];
                                          } else {
                                              [[[UIAlertView alloc] initWithTitle:@"Error"
                                                                          message:error.localizedDescription
                                                                         delegate:nil
                                                                cancelButtonTitle:@"OK"
                                                                otherButtonTitles:nil]
                                               show];
                                          }
                                      }];

        return;
    }
    
    [FBRequestConnection startWithGraphPath:@"/me/taggable_friends"
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        
        if (!error) {
            
            NSLog(@"results: %@", result);
            
            self.data = result[@"data"];
            [self.data sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
            
            [self.tableView reloadData];
        }
                              
        [self.activityIndicator stopAnimating];

    }];
    

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonPressed:(id)sender {
    self.selectHandler(self.selectedFriends);
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
    
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [searchBar resignFirstResponder];

    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.data.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (!self.searchBar.text.length) {
        return 1;
    }

    NSDictionary* friend = self.data[section];
    
    if ([friend[@"name"] rangeOfString:self.searchBar.text options:NSCaseInsensitiveSearch].location == NSNotFound) {
        return 0;
    }
    
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FriendCell* cell = [tableView dequeueReusableCellWithIdentifier:@"FriendCell"];
    
    NSDictionary* friend = self.data[indexPath.section];
    
    cell.nameLabel.text = friend[@"name"];
    [cell.pictureImageView loadImageWithPath:friend[@"picture"][@"data"][@"url"] completion:^(BOOL didLoadImage) {
        
    }];
    
    cell.checkmarkImageView.hidden = ![self.selectedFriends containsObject:friend];

    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSDictionary* friend = self.data[indexPath.section];

    if ([self.selectedFriends containsObject:friend]) {
        [self.selectedFriends removeObject:friend];
    }
    else {
        [self.selectedFriends addObject:friend];
    }
    
    [tableView reloadData];
    FriendCell* cell = (FriendCell*) [tableView cellForRowAtIndexPath:indexPath];
    
    cell.checkmarkImageView.hidden = ![self.selectedFriends containsObject:friend];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
