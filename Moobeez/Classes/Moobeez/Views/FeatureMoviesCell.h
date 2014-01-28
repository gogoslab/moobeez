//
//  FeatureMoviesCell.h
//  Moobeez
//
//  Created by Radu Banea on 22/01/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MoviePosterView;

@interface FeatureMoviesCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) NSArray* movies;
@property (readwrite, nonatomic) BOOL isReverse;

@property (weak, nonatomic) UITableView* parentTableView;

- (void)startAnimating;
- (void)stopAnimating;

- (IBAction)didPanned:(id)sender;

- (MoviePosterView*)posterViewWithIndex:(NSInteger)index;

@end
