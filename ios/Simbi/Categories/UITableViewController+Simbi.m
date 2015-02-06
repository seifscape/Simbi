//
//  UITableViewController+Simbi.m
//  Simbi
//
//  Created by flynn on 8/13/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "UITableViewController+Simbi.h"


@implementation UITableViewController (Simbi)

- (CGFloat)requiredHeightForTable
{
    // Counts up the heights of all of the headers, footers, and rows in the table.
    
    CGFloat requiredHeight = 0;
    
    for (int i = 0; i < self.tableView.numberOfSections; i++)
    {
        requiredHeight += [self tableView:self.tableView heightForHeaderInSection:i];
        
        int numRows = [self.tableView numberOfRowsInSection:i];
        for (int l = 0; l < numRows; l++)
            requiredHeight += [self tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:l inSection:i]];
        
        requiredHeight += [self tableView:self.tableView heightForFooterInSection:i];
    }
    
    return requiredHeight;
}

@end
