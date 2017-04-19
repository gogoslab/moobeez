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

@property (weak, nonatomic) IBOutlet UIView* animatedView;
@property (readwrite, nonatomic) CGRect initialAnimatedFrame;

@end

@implementation CharacterTableCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.posterImageView.loadSyncronized = YES;
}

- (void)setCharacter:(TmdbCharacter *)character {
    
    _character = character;
    
    if (character.person) {
        self.posterImageView.layer.cornerRadius = self.posterImageView.width / 2;
        [self.posterImageView loadProfileWithPath:character.person.profilePath completion:^(BOOL didLoadImage) {}];
        self.titleLabel.text = character.person.name;
    }
    else if (character.movie) {
        [self.posterImageView loadPosterWithPath:character.movie.posterPath completion:^(BOOL didLoadImage) {}];
        self.titleLabel.text = character.movie.name;
    }
    else if (character.tv) {
        [self.posterImageView loadPosterWithPath:character.tv.posterPath completion:^(BOOL didLoadImage) {}];
        self.titleLabel.text = character.tv.name;
    }
 
    self.detailsLabel.text = [NSString stringWithFormat:@"as %@", character.name];
    self.detailsLabel.hidden = (character.name.length == 0);

}

- (void)animateGrowWithCompletion:(void (^)(void))completionHandler {
    
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    self.initialAnimatedFrame = self.animatedView.frame;
    
    self.animatedView.center = [appDelegate.window convertPoint:self.animatedView.center fromView:self.animatedView.superview];
    [appDelegate.window addSubview:self.animatedView];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.animatedView.frame = appDelegate.window.bounds;
    } completion:^(BOOL finished) {
        [self performSelector:@selector(returnToNormalState) withObject:nil afterDelay:0.1];
        
        completionHandler();
    }];
    
    self.posterImageView.defaultImage = self.posterImageView.image;
    
    if (self.character.person) {
        self.posterImageView.layer.cornerRadius = 0;
        [self.posterImageView loadProfileWithPath:self.character.person.profilePath completion:^(BOOL didLoadImage) {}];
    }
    else if (self.character.movie) {
        [self.posterImageView loadPosterWithPath:self.character.movie.posterPath completion:^(BOOL didLoadImage) {}];
    }
    else if (self.character.tv) {
        [self.posterImageView loadPosterWithPath:self.character.tv.posterPath completion:^(BOOL didLoadImage) {}];
    }
}

- (void)returnToNormalState {
    self.animatedView.frame = self.bounds;
    [self addSubview:self.animatedView];
}

- (void)prepareForShrink {
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    self.animatedView.frame = appDelegate.window.bounds;
    [appDelegate.window addSubview:self.animatedView];
}

- (void)animateShrinkWithCompletion:(void (^)(void))completionHandler {
    
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    [self prepareForShrink];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.animatedView.frame = [appDelegate.window convertRect:self.initialAnimatedFrame fromView:self];
    } completion:^(BOOL finished) {
        self.animatedView.frame = self.initialAnimatedFrame;
        [self addSubview:self.animatedView];
        
        completionHandler();
    }];
    
    if (self.character.person) {
        self.posterImageView.layer.cornerRadius = self.posterImageView.width / 2;
        [self.posterImageView loadProfileWithPath:self.character.person.profilePath completion:^(BOOL didLoadImage) {}];
    }
    else if (self.character.movie) {
        [self.posterImageView loadPosterWithPath:self.character.movie.posterPath completion:^(BOOL didLoadImage) {}];
    }
    else if (self.character.tv) {
        [self.posterImageView loadPosterWithPath:self.character.tv.posterPath completion:^(BOOL didLoadImage) {}];
    }
}
@end
