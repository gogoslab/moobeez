//
//  ToolboxView.h
//  Moobeez
//
//  Created by Radu Banea on 10/23/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TmdbCharacter;
@class CharacterCell;

typedef void (^CharacterCellSelectionHandler) (TmdbCharacter* tmdbCharacter, CharacterCell* cell);

@class ToolboxView;

@protocol ToolboxViewDelegate <NSObject>

@optional

- (void)toolboxViewWillShow:(ToolboxView*)toolboxView;
- (void)toolboxViewDidShow:(ToolboxView*)toolboxView;
- (void)toolboxViewWillHide:(ToolboxView*)toolboxView;
- (void)toolboxViewDidHide:(ToolboxView*)toolboxView;

@end

@interface ToolboxView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *blurImageView;

@property (readwrite, nonatomic) CGFloat minToolboxY;
@property (readwrite, nonatomic) CGFloat maxToolboxY;

@property (readwrite, nonatomic) BOOL isLightInterface;

@property (weak, nonatomic) IBOutlet id<ToolboxViewDelegate> delegate;

- (void)showFullToolbox;
- (void)hideFullToolbox;

- (void)prepareBlurInView:(UIView*)view;
- (void)addToSuperview:(UIView*)view;

@end
