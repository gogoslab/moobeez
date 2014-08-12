//
//  PlacePickerViewController.h
//  Moobeez
//
//  Created by Radu Banea on 21/07/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "ViewController.h"

@interface PlacePickerViewController : ViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *placesTableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *placesActivityIndicator;

@property (strong, nonatomic) NSMutableArray* data;

@property (strong, nonatomic) NSString* searchText;
@property (readwrite, nonatomic) NSInteger radius;
@property (readwrite, nonatomic) NSInteger resultsLimit;

- (void)refresh;

@end
