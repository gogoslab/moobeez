//
//  SearchCategoryController.h
//  Moobeez
//
//  Created by Radu Banea on 09/05/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SearchConnection.h"

@class SearchViewController;

@interface SearchCategoryController : NSObject

@property (strong, nonatomic) NSMutableArray* results;

@property (readwrite, nonatomic) NSInteger page;

@property (readwrite, nonatomic) NSInteger numberOfPages;

@property (strong, nonatomic) SearchConnection* connection;

@property (readwrite, nonatomic) SearchConnectionType type;

@property (weak, nonatomic) SearchViewController* parentViewController;

- (void)reloadData:(BOOL)newData;

@end