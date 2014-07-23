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

@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (weak, nonatomic) IBOutlet ImageView *posterImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView* animatedView;

@property (readwrite, nonatomic) CGRect initialAnimatedFrame;
@property (readwrite, nonatomic) CGRect windowAnimatedFrame;

@end

@implementation CharacterCell

- (void)awakeFromNib {
}

- (void)setCharacter:(TmdbCharacter *)character {
    
    _character = character;
    
    if (character.person) {
        self.posterImageView.layer.cornerRadius = self.posterImageView.width / 2;
        [self.posterImageView loadImageWithPath:character.person.profilePath andWidth:185 completion:^(BOOL didLoadImage) {}];
    }
    else if (character.movie) {
        [self.posterImageView loadImageWithPath:character.movie.posterPath andWidth:154 completion:^(BOOL didLoadImage) {}];
    }
    else if (character.tv) {
        [self.posterImageView loadImageWithPath:character.tv.posterPath andWidth:154 completion:^(BOOL didLoadImage) {}];
    }

    self.titleLabel.text = character.name;
    
}

- (void)animateGrowWithCompletion:(void (^)(void))completionHandler {
    
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;

    self.initialAnimatedFrame = self.animatedView.frame;
    
    self.animatedView.center = [appDelegate.window convertPoint:self.animatedView.center fromView:self.animatedView.superview];
    [appDelegate.window addSubview:self.animatedView];
    
    self.windowAnimatedFrame = self.animatedView.frame;
    
    [UIView animateWithDuration:0.5 animations:^{
        self.posterImageView.layer.cornerRadius = 0;
        self.animatedView.frame = appDelegate.window.bounds;
    } completion:^(BOOL finished) {
        
        [self performSelector:@selector(returnToNormalState) withObject:nil afterDelay:0.1];
        
        completionHandler();
    }];
    
    self.posterImageView.defaultImage = self.posterImageView.image;
    
    if (self.character.person) {
        [self.posterImageView loadImageWithPath:self.character.person.profilePath andHeight:632 completion:^(BOOL didLoadImage) {}];
    }
    else if (self.character.movie) {
        [self.posterImageView loadImageWithPath:self.character.movie.posterPath andWidth:500 completion:^(BOOL didLoadImage) {}];
    }
    else if (self.character.tv) {
        [self.posterImageView loadImageWithPath:self.character.tv.posterPath andWidth:500 completion:^(BOOL didLoadImage) {}];
    }
}

- (void)returnToNormalState {
    self.animatedView.frame = self.bounds;
    [self.containerView addSubview:self.animatedView];
}

- (void)prepareForShrink {
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    self.animatedView.frame = appDelegate.window.bounds;
    [appDelegate.window addSubview:self.animatedView];
}

- (void)animateShrinkWithCompletion:(void (^)(void))completionHandler {
    
    [self prepareForShrink];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.animatedView.frame = self.windowAnimatedFrame;
    } completion:^(BOOL finished) {
        self.animatedView.frame = self.initialAnimatedFrame;
        [self addSubview:self.animatedView];
        
        completionHandler();
    }];
    
    if (self.character.person) {
        self.posterImageView.layer.cornerRadius = self.posterImageView.width / 2;
        [self.posterImageView loadImageWithPath:self.character.person.profilePath andWidth:185 completion:^(BOOL didLoadImage) {}];
    }
    else if (self.character.movie) {
        [self.posterImageView loadImageWithPath:self.character.movie.posterPath andWidth:154 completion:^(BOOL didLoadImage) {}];
    }
    else if (self.character.tv) {
        [self.posterImageView loadImageWithPath:self.character.tv.posterPath andWidth:154 completion:^(BOOL didLoadImage) {}];
    }
}

@end
