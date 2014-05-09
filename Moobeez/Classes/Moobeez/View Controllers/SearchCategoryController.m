//
//  SearchCategoryController.m
//  Moobeez
//
//  Created by Radu Banea on 09/05/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "SearchCategoryController.h"
#import "Moobeez.h"

@implementation SearchCategoryController

- (void)reloadData:(BOOL)newData {
    
    if (self.connection) {
        return;
    }
    
    if (newData) {
        self.page = 1;
        self.results = [[NSMutableArray alloc] init];
    }
    else {
        self.page++;
    }
    
    self.connection = [[SearchConnection alloc] initWithQuery:self.parentViewController.searchBar.text type:self.type page:self.page completionHandler:^(WebserviceResultCode code, NSMutableArray *results, NSInteger numberOfPages) {
        
        if (code == WebserviceResultOk) {
            [self.results addObjectsFromArray:results];
            self.numberOfPages = numberOfPages;
            
            [self.parentViewController reloadSearchType:self.type];
        }
        
        self.connection = nil;
    }];
    
    [[ConnectionsManager sharedManager] startConnection:self.connection];
    
}

@end
