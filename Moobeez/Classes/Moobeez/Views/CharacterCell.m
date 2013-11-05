//
//  CharacterCell.m
//  Moobeez
//
//  Created by Radu Banea on 10/23/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "CharacterCell.h"
#import "Moobeez.h"

@interface CharacterCell ()

@property (weak, nonatomic) IBOutlet ImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation CharacterCell

- (void)awakeFromNib {
}

- (void)setCharacter:(TmdbCharacter *)character {
    
    _character = character;
    
    if (character.person) {
        self.imageView.layer.cornerRadius = self.imageView.width / 2;
        [self.imageView loadImageWithPath:character.person.profilePath andWidth:185 completion:^(BOOL didLoadImage) {}];
    }
    else if (character.movie) {
        [self.imageView loadImageWithPath:character.movie.posterPath andWidth:154 completion:^(BOOL didLoadImage) {}];
    }

    self.titleLabel.text = character.name;
}

@end
