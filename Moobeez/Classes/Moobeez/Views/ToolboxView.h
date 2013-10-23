//
//  ToolboxView.h
//  Moobeez
//
//  Created by Radu Banea on 10/23/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ToolboxView : UIView

@property (readwrite, nonatomic) CGFloat minToolboxY;
@property (readwrite, nonatomic) CGFloat maxToolboxY;

- (void)showFullToolbox;
- (void)hideFullToolbox;

@end
