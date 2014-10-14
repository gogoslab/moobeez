//
//  SortingView.h
//  Moobeez
//
//  Created by Radu Banea on 13/10/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    SortingLeft,
    SortingRight,
} SortingDirection;

@class SortingView;

@protocol SortingViewDataSource <NSObject>

- (NSInteger)numberOfCardsInSortingView:(SortingView*)sortingView;
- (UIView*)sortingView:(SortingView*)sortingView viewForCardIndex:(NSInteger)cardIndex;

@optional
- (UIView*)sortingView:(SortingView*)sortingView coverViewForCard:(UIView*)cardView direction:(SortingDirection)direction;

@end

@protocol SortingViewDelegate <NSObject>

@optional
- (void)sortingView:(SortingView*)sortingView didSortCardAtIndex:(NSInteger)cardIndex direction:(SortingDirection)direction;
- (void)sortingView:(SortingView*)sortingView didSelectCardAtIndex:(NSInteger)cardIndex;

@end

@interface SortingView : UIView

@property (weak, nonatomic) IBOutlet id<SortingViewDataSource> dataSource;
@property (weak, nonatomic) IBOutlet id<SortingViewDelegate> delegate;

@property (readwrite, nonatomic) CGSize cardSize;
@property (readonly, nonatomic) CGRect cardFrame;

@property (readwrite, nonatomic) CGFloat numberOfVisibleCards;

@property (readonly, nonatomic) UIView* topCardView;

- (void)reloadData;

- (UIView*)dequeueReusableCard;

@end
