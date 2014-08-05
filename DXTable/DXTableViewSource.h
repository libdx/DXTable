//
//  DXTableViewSource.h
//  Pieces
//
//  Created by Alexander Ignatenko on 22/05/14.
//  Copyright (c) 2014 Alexander Ignatenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DXTableModel;

@interface DXTableViewSourceOptions : NSObject

@property (nonatomic, unsafe_unretained) Class cellClass;

@end

@interface DXTableViewSource : NSObject <UITableViewDataSource, UITableViewDelegate>

// sets tableView delegate and dataSource to self and registers cell resources (classes and nibs) provided by tableModel.
- (instancetype)initWithTableView:(UITableView *)tableView
                       tableModel:(DXTableModel *)tableModel
                          options:(DXTableViewSourceOptions *)options;

@end
