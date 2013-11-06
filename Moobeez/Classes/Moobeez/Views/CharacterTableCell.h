//
//  CharacterTableCell.h
//  Moobeez
//
//  Created by Radu Banea on 05/11/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TmdbCharacter;

@interface CharacterTableCell : UITableViewCell

@property (strong, nonatomic) TmdbCharacter* character;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (void)animateGrowWithCompletion:(void (^)(void))completionHandler;
- (void)prepareForShrink;
- (void)animateShrinkWithCompletion:(void (^)(void))completionHandler;

@end
