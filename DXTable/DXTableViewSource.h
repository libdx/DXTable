//
//  DXTableViewSource.h
//  Pieces
//
//  Created by Alexander Ignatenko on 22/05/14.
//  Copyright (c) 2014 Alexander Ignatenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DXTableModel;

@interface DXTableViewSource : NSObject <UITableViewDataSource, UITableViewDelegate>

- (instancetype)initWithTableView:(UITableView *)tableView
                       tableModel:(DXTableModel *)tableModel
                      dataContext:(id)dataContext
                          options:(NSDictionary *)options;

@end

extern NSString *DXTableViewSourceCellClassKey;
extern NSString *DXTableViewSourceInsertAnimationKey;
