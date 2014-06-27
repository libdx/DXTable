//
//  DXTableSection.h
//  Pieces
//
//  Created by Alexander Ignatenko on 22/05/14.
//  Copyright (c) 2014 Alexander Ignatenko. All rights reserved.
//

#import "DXTableItem.h"

@class DXTableModel, DXTableRowArray;

extern NSString *const DXTableRowsKey;

//extern NSString *const DXTableSectionHeaderView;
//extern NSString *const DXTableSectionFooterView;
//extern NSString *const DXTableSectionHeaderClass;
//extern NSString *const DXTableSectionFooterClass;

@interface DXTableSection : DXTableItem

@property (nonatomic, weak, readonly) DXTableModel *tableModel;

@property (nonatomic, readonly) NSArray *allRows;
@property (nonatomic, readonly) DXTableRowArray *activeRows;

//@property (nonatomic, readonly) DXTableItem *header;
//@property (nonatomic, readonly) DXTableItem *footer;

- (instancetype)initWithModel:(DXTableModel *)tableModel
                      options:(NSDictionary *)options;

@end
