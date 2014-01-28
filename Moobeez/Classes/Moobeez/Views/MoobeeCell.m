//
//  MoobeeCell.m
//  Moobeez
//
//  Created by Radu Banea on 10/14/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "MoobeeCell.h"
#import "Moobeez.h"

@interface MoobeeCell ()

@property (weak, nonatomic) IBOutlet UIView* contentView;

@property (weak, nonatomic) IBOutlet ImageView *posterImageView;
@property (weak, nonatomic) IBOutlet StarsView *starsView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation MoobeeCell

- (void)awakeFromNib {
    
    self.layer.masksToBounds = NO;
    self.layer.shadowOffset = CGSizeMake(2, 3);
    self.layer.shadowRadius = 4;
    self.layer.shadowOpacity = 0.2;
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
}

- (void)setMoobee:(Moobee *)moobee {
    _moobee = moobee;
    
    self.nameLabel.text = moobee.name;
    
    self.starsView.rating = self.moobee.rating;

    self.posterImageView.defaultImage = [UIImage imageNamed:@"default_image.png"];
    self.posterImageView.loadSyncronized = YES;
    [self.posterImageView loadImageWithPath:moobee.posterPath andWidth:185 completion:^(BOOL didLoadImage) {
        self.nameLabel.hidden = didLoadImage;
    }];
    
    self.starsView.hidden = (moobee.type != MoobeeSeenType);
}

- (void)drawRect:(CGRect)rect {
    self.starsView.rating = self.moobee.rating;

    [super drawRect:rect];
}

- (void)animateGrowWithCompletion:(void (^)(void))completionHandler {
    
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    self.contentView.frame = self.bounds;
    [self addSubview:self.contentView];
    
    self.contentView.center = [appDelegate.window convertPoint:self.contentView.center fromView:self.contentView.superview];
    [appDelegate.window addSubview:self.contentView];

    self.starsView.hidden = YES;

    [UIView animateWithDuration:0.5 animations:^{
        self.contentView.frame = appDelegate.window.bounds;
    } completion:^(BOOL finished) {
        self.contentView.frame = self.bounds;
        [self addSubview:self.contentView];
        
        completionHandler();
    }];
    
    self.posterImageView.defaultImage = self.posterImageView.image;
    [self.posterImageView loadImageWithPath:self.moobee.posterPath andWidth:500 completion:^(BOOL didLoadImage) {}];
}

- (void)prepareForShrink {
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    self.contentView.frame = appDelegate.window.bounds;
    [appDelegate.window addSubview:self.contentView];
    
    self.starsView.hidden = YES;
}

- (void)animateShrinkWithCompletion:(void (^)(void))completionHandler {
    
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    [self prepareForShrink];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.contentView.frame = [appDelegate.window convertRect:self.frame fromView:self.superview];
    } completion:^(BOOL finished) {
        self.contentView.frame = self.bounds;
        [self addSubview:self.contentView];
        
        self.starsView.hidden = (self.moobee.type != MoobeeSeenType);

        completionHandler();
    }];
    
    [self.posterImageView loadImageWithPath:self.moobee.posterPath andWidth:185 completion:^(BOOL didLoadImage) {}];
}


+ (CGFloat)cellHeight {

    static CGFloat cellHeight = -1;
    
    if (cellHeight == -1) {
        
        MoobeeCell* cell = [[NSBundle mainBundle] loadNibNamed:@"MoobeeCell" owner:self options:nil][0];
        
        UIWindow* window = ((AppDelegate*) [UIApplication sharedApplication].delegate).window;
        
        cellHeight = cell.width * window.height / window.width;
        
    }
    
    return cellHeight;
}

@end
