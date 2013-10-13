//
//  UITableView+Extra.m
//  Gogz
//
//  Created by Radu Banea on 10/11/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "UITableView+Extra.h"

@implementation UITableView (Extra)

- (CGFloat)tableViewHeight {
    CGFloat height = 0.0;
 
    NSInteger nbSections = [self.dataSource numberOfSectionsInTableView:self];
    
    for (int section = 0; section < nbSections; ++section) {
        NSInteger nbRows = [self.dataSource tableView:self numberOfRowsInSection:section];
        
        if ([self.delegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)]) {
            for (int row = 0; row < nbRows; ++row) {
                height += [self.delegate tableView:self heightForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
            }
        }
        else {
            height += self.rowHeight * nbRows;
        }
    }
    
    return height;
}

@end
