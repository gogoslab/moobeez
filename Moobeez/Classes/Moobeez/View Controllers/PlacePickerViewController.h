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
@property (strong, nonatomic) NSMutableArray* data;

@property (strong, nonatomic) NSString* searchText;
@property (readwrite, nonatomic) NSInteger radius;
@property (readwrite, nonatomic) NSInteger resultsLimit;

@end
