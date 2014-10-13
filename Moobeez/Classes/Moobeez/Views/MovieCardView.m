//
//  MovieCardView.m
//  Moobeez
//
//  Created by Radu Banea on 13/10/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "MovieCardView.h"
#import "Moobeez.h"

@interface MovieCardView ()

@property (weak, nonatomic) IBOutlet ImageView* posterImageView;

@property (readwrite, nonatomic) BOOL isLightInterface;

@property (weak, nonatomic) IBOutlet UILabel *rightCoverLabel;
@property (weak, nonatomic) IBOutlet UIImageView *rightCoverIcon;

@property (weak, nonatomic) IBOutlet UILabel *leftCoverLabel;
@property (weak, nonatomic) IBOutlet UIImageView *leftCoverIcon;

@end

@implementation MovieCardView

- (void)awakeFromNib {
    self.layer.cornerRadius = 6;
    self.layer.shadowOffset = CGSizeMake(0, 2);
    self.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.layer.shadowOpacity = 0.3;
}

- (void)setMovie:(TmdbMovie *)movie {

    _movie = movie;
    
    [self.posterImageView loadPosterWithPath:movie.posterPath completion:^(BOOL didLoadImage) {
        
        self.isLightInterface = ([self.posterImageView.image luminosity] <= 60);
        
    }];
    
}

- (void)setIsLightInterface:(BOOL)isLightInterface {
    
    _isLightInterface = isLightInterface;
    
    UIColor* textsColor = (self.isLightInterface ? [UIColor whiteColor] : [UIColor blackColor]);
    
    self.rightCoverLabel.textColor = textsColor;
    NSBundle* bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:(self.isLightInterface ? @"MovieButtonsWhite" : @"MovieButtonsBlack") ofType:@"bundle"]];
    self.rightCoverIcon.image = [UIImage imageWithContentsOfFile:[bundle pathForResource:ResourceName(@"button_wishlist_add") ofType:@"png"]];
    
    self.leftCoverLabel.textColor = textsColor;
    self.leftCoverIcon.image = [UIImage imageNamed:[NSString stringWithFormat:@"garbage_icon_%@.png", (self.isLightInterface ? @"white" : @"black")]];
}

@end
