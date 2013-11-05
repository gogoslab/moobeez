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

@end
