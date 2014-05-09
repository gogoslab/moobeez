//
//  SearchViewController.h
//  Moobeez
//
//  Created by Radu Banea on 09/05/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "ViewController.h"
#import "SearchConnection.h"

@class SearchCategoryController;

@interface SearchViewController : ViewController

@property (strong, nonatomic) IBOutlet UISearchBar* searchBar;

- (void)performSearch;
- (void)reloadSearchType:(SearchConnectionType)type;

@end
