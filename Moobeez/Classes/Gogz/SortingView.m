//
//  SortingView.m
//  Moobeez
//
//  Created by Radu Banea on 13/10/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "SortingView.h"
#import "UIView+Extra.h"

@interface SortingView ()

@property (strong, nonatomic) NSMutableArray* visibleCards;
@property (readwrite, nonatomic) CGPoint cardLastPosition;
@property (readwrite, nonatomic) NSInteger firstVisibleCardIndex;

@property (readonly, nonatomic) CGRect cardFrame;

@property (weak, nonatomic) UIView* coverView;

@end

@implementation SortingView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {

    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.numberOfVisibleCards = 3;
        self.cardSize = CGSizeMake(self.width * 0.8, self.height * 0.8);
        
        self.visibleCards = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (CGRect)cardFrame {
    return CGRectMake((self.width - self.cardSize.width) / 2, (self.height - self.cardSize.height) / 2, self.cardSize.width, self.cardSize.height);
}

- (void)reloadData {
    
    for (UIView* cardView in self.visibleCards) {
        [cardView removeFromSuperview];
    }
    [self.visibleCards removeAllObjects];
    
    
    
    self.firstVisibleCardIndex = [self.dataSource numberOfCardsInSortingView:self] - 1;
    
    for (NSInteger cardIndex = self.firstVisibleCardIndex; cardIndex >= MAX(self.firstVisibleCardIndex - self.numberOfVisibleCards + 1, 0); --cardIndex) {
        [self addCardForIndex:cardIndex];
    }
    
    [self reloadCards];
}

- (void)addCardForIndex:(NSInteger)cardIndex {
    UIView* cardView = [self.dataSource sortingView:self viewForCardIndex:cardIndex];
    cardView.frame = self.cardFrame;
    
    if (self.visibleCards.count) {
        [self insertSubview:cardView belowSubview:self.visibleCards.lastObject];
    }
    else {
        [self addSubview:cardView];
    }
    
    [self.visibleCards addObject:cardView];
    
    NSInteger visibleIndex = [self.visibleCards indexOfObject:cardView];
    
    if (visibleIndex > 0) {
        
        CGFloat scaleValue = 1.0 - visibleIndex * 0.05;
        
        cardView.transform = CGAffineTransformTranslate(CGAffineTransformMakeScale(scaleValue, scaleValue), 0, self.cardFrame.size.height * (visibleIndex * 0.05));
    }

}

- (void)reloadCards {
    
    for (UIView* cardView in self.visibleCards) {
        
        NSInteger visibleIndex = [self.visibleCards indexOfObject:cardView];
        
        CGFloat scaleValue = 1.0 - visibleIndex * 0.05;
        
        cardView.transform = CGAffineTransformTranslate(CGAffineTransformMakeScale(scaleValue, scaleValue), 0, self.cardFrame.size.height * (visibleIndex * 0.05));
        
        if (visibleIndex == 0) {
            [self addGesturesToCardView:cardView];
        }
    }
}

- (void)addGesturesToCardView:(UIView*)cardView {
    
    UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didMoveCardView:)];
    [cardView addGestureRecognizer:panGesture];
    
}

- (IBAction)didMoveCardView:(UIGestureRecognizer*)gestureRecognizer {
    
    CGPoint point = [gestureRecognizer locationInView:self];
    
    UIView* cardView = gestureRecognizer.view;
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint center = cardView.center;
            center.x += point.x - self.cardLastPosition.x;
            center.y += point.y - self.cardLastPosition.y;
            cardView.center = center;
            
            CGFloat xDiff = center.x - self.width / 2;
            cardView.transform = CGAffineTransformMakeRotation(xDiff / (self.width / 2) * (M_PI / 12));
            
            [self.coverView removeFromSuperview];
            if ([self.dataSource respondsToSelector:@selector(sortingView:coverViewForCard:direction:)]) {
                self.coverView = [self.dataSource sortingView:self coverViewForCard:cardView direction:(xDiff < 0 ? SortingLeft : SortingRight)];

                [cardView addSubview:self.coverView];
                self.coverView.alpha = 0.8 * MIN(1.0, (2 * fabs(xDiff) / (self.width / 2)));

            }
            
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            CGPoint center = cardView.center;
            
            if (center.x < self.width / 4) {
                [self discardCardToDirection:SortingLeft];
            }
            else if (center.x > 3 * self.width / 4) {
                [self discardCardToDirection:SortingRight];
            }
            else {
                [UIView animateWithDuration:0.3 animations:^{
                    cardView.center = CGPointMake(self.width / 2, self.height / 2);
                    cardView.transform = CGAffineTransformIdentity;
                    [self.coverView removeFromSuperview];
                }];
            }
        }
        default:
            break;
    }
    
    self.cardLastPosition = point;
    
}

- (void)discardCardToDirection:(SortingDirection)direction {

    UIView* cardView = self.visibleCards[0];
    
    [self.visibleCards removeObjectAtIndex:0];
    
    self.firstVisibleCardIndex--;
    
    if (self.firstVisibleCardIndex - self.numberOfVisibleCards + 1 >= 0) {
        [self addCardForIndex:self.firstVisibleCardIndex - self.numberOfVisibleCards + 1];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        
        switch (direction) {
            case SortingLeft:
                cardView.center = CGPointMake(- cardView.width, cardView.center.y);
                break;
                
            case SortingRight:
                cardView.center = CGPointMake(self.width + cardView.width, cardView.center.y);
                break;
                
            default:
                break;
        }
        
        CGFloat xDiff = cardView.center.x - self.width / 2;
        cardView.transform = CGAffineTransformMakeRotation(xDiff / (self.width / 2) * (M_PI / 12));
        
        [self reloadCards];
        
    } completion:^(BOOL finished) {
        if ([self.delegate respondsToSelector:@selector(sortingView:didSortCardAtIndex:direction:)]) {
            [self.delegate sortingView:self didSortCardAtIndex:self.firstVisibleCardIndex + 1 direction:direction];
        }
        [cardView removeFromSuperview];
    }];
}

@end
