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

// sets tableView delegate and dataSource to self and registers cell resources (classes and nibs) provided by tableModel.
- (instancetype)initWithTableView:(UITableView *)tableView
                       tableModel:(DXTableModel *)tableModel
                          options:(NSDictionary *)options;

@end

extern NSString *DXTableViewSourceCellClassKey;
extern NSString *DXTableViewSourceInsertAnimationKey;
extern NSString *DXTableViewSourceUseLocalizedStringKey;
extern NSString *DXTableViewSourceCanEditRowsKey; // are rows editable by default
