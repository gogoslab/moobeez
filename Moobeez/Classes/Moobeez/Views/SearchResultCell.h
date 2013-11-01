//
//  SearchResultCell.h
//  Moobeez
//
//  Created by Radu Banea on 01/11/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TmdbMovie;
@class TmdbPerson;

@interface SearchResultCell : UITableViewCell

@property (strong, nonatomic) TmdbMovie* tmdbMovie;
@property (strong, nonatomic) TmdbPerson* tmdbPerson;

@end
