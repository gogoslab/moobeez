//
//  CharacterCell.h
//  Moobeez
//
//  Created by Radu Banea on 10/23/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TmdbCharacter;

@interface CharacterCell : UICollectionViewCell

@property (strong, nonatomic) TmdbCharacter* character;

@end
