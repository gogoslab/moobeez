//
//  CharacterTableCell.m
//  Moobeez
//
//  Created by Radu Banea on 05/11/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "CharacterTableCell.h"
#import "Moobeez.h"

@interface CharacterTableCell ()

@property (weak, nonatomic) IBOutlet ImageView *posterImageView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *detailsLabel;

@end

@implementation CharacterTableCell

- (void)awakeFromNib {
    self.posterImageView.layer.cornerRadius = self.posterImageView.width / 2;
    self.posterImageView.loadSyncronized = YES;
}

- (void)setCharacter:(TmdbCharacter *)character {
    
    _character = character;
    
    if (character.person) {
        [self.posterImageView loadImageWithPath:character.person.profilePath andWidth:185 completion:^(BOOL didLoadImage) {}];
        self.titleLabel.text = character.person.name;
    }
    else if (character.movie) {
        [self.posterImageView loadImageWithPath:character.movie.posterPath andWidth:154 completion:^(BOOL didLoadImage) {}];
        self.titleLabel.text = character.movie.name;
    }
 
    self.detailsLabel.text = [NSString stringWithFormat:@"as %@", character.name];

}


@end
