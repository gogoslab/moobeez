//
//  BeeCell.m
//  Moobeez
//
//  Created by Radu Banea on 10/14/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "BeeCell.h"
#import "Moobeez.h"

@interface BeeCell ()

@property (weak, nonatomic) IBOutlet UIView* contentView;

@property (weak, nonatomic) IBOutlet ImageView *posterImageView;
@property (weak, nonatomic) IBOutlet StarsView *starsView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation BeeCell

- (void)awakeFromNib {
    
    self.layer.masksToBounds = NO;
    self.layer.shadowOffset = CGSizeMake(2, 3);
    self.layer.shadowRadius = 4;
    self.layer.shadowOpacity = 0.2;
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
    self.notWatchedEpisodesLabel.layer.cornerRadius = self.notWatchedEpisodesLabel.width / 2;
    self.notWatchedEpisodesLabel.layer.shadowRadius = 2;
    self.notWatchedEpisodesLabel.layer.shadowOpacity = 0.6;
    self.notWatchedEpisodesLabel.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.notWatchedEpisodesLabel.bounds].CGPath;

}

- (void)setBee:(Bee *)bee {
    _bee = bee;
    
    self.nameLabel.text = self.bee.name;
    

    self.posterImageView.defaultImage = [UIImage imageNamed:@"default_image.png"];
    self.posterImageView.loadSyncronized = YES;
    [self.posterImageView loadImageWithPath:self.bee.posterPath andWidth:185 completion:^(BOOL didLoadImage) {
        self.nameLabel.hidden = didLoadImage;
    }];
    
    self.starsView.hidden = NO;
    
    if (self.bee.rating >= 0) {
        self.starsView.rating = self.bee.rating;
    }
    else {
        self.starsView.hidden = YES;
    }
    
    if ([self.bee isKindOfClass:[Moobee class]]) {
        self.starsView.hidden = (((Moobee*) self.bee).type != MoobeeSeenType);
    }
    
    if ([self.bee isKindOfClass:[Teebee class]]) {
        self.notWatchedEpisodesLabel.text = StringInteger((long)((Teebee*) self.bee).notWatchedEpisodesCount);
        self.notWatchedEpisodesLabel.hidden = (((Teebee*) self.bee).notWatchedEpisodesCount <= 0);
    }
    
}

- (void)drawRect:(CGRect)rect {
    if (self.bee.rating >= 0) {
        self.starsView.rating = self.bee.rating;
    }
    else {
        self.starsView.hidden = YES;
    }

    [super drawRect:rect];
}

- (void)animateGrowWithCompletion:(void (^)(void))completionHandler {
    
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    self.posterImageView.center = [appDelegate.window convertPoint:self.posterImageView.center fromView:self.posterImageView.superview];
    [appDelegate.window addSubview:self.posterImageView];

    self.starsView.hidden = YES;
    self.notWatchedEpisodesLabel.hidden = YES;

    [UIView animateWithDuration:0.5 animations:^{
        self.posterImageView.frame = appDelegate.window.bounds;
    } completion:^(BOOL finished) {

        [self performSelector:@selector(returnToNormalState) withObject:nil afterDelay:0.01];
        
        completionHandler();
    }];
    
    self.posterImageView.defaultImage = self.posterImageView.image;
    [self.posterImageView loadImageWithPath:self.bee.posterPath andWidth:500 completion:^(BOOL didLoadImage) {}];
}

- (void)prepareForShrink {
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    self.posterImageView.frame = appDelegate.window.bounds;
    [appDelegate.window addSubview:self.posterImageView];
    
    self.starsView.hidden = YES;
    self.notWatchedEpisodesLabel.hidden = YES;
}

- (void)animateShrinkWithCompletion:(void (^)(void))completionHandler {
    
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    [self prepareForShrink];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.posterImageView.frame = [appDelegate.window convertRect:self.frame fromView:self.superview];
    } completion:^(BOOL finished) {
        [self returnToNormalState];
        
        self.starsView.hidden = NO;
        
        if ([self.bee isKindOfClass:[Moobee class]]) {
            self.starsView.hidden = (((Moobee*) self.bee).type != MoobeeSeenType);
        }
        if ([self.bee isKindOfClass:[Teebee class]]) {
            self.notWatchedEpisodesLabel.hidden = (((Teebee*) self.bee).notWatchedEpisodesCount <= 0);
        }


        completionHandler();
    }];
    
    [self.posterImageView loadImageWithPath:self.bee.posterPath andWidth:185 completion:^(BOOL didLoadImage) {}];
}

- (void)returnToNormalState {
    self.posterImageView.frame = self.bounds;
    [self.contentView insertSubview:self.posterImageView atIndex:0];
}


+ (CGFloat)cellHeight {

    static CGFloat cellHeight = -1;
    
    if (cellHeight == -1) {
        
        BeeCell* cell = [[NSBundle mainBundle] loadNibNamed:@"BeeCell" owner:self options:nil][0];
        
        UIWindow* window = ((AppDelegate*) [UIApplication sharedApplication].delegate).window;
        
        cellHeight = cell.width * window.height / window.width;
        
    }
    
    return cellHeight;
}

@end
