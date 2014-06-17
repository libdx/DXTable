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

@interface DXTableSection : DXTableItem

@property (nonatomic, weak, readonly) DXTableModel *tableModel;

@property (nonatomic, readonly) NSArray *allRows;
@property (nonatomic, readonly) DXTableRowArray *activeRows;

- (instancetype)initWithModel:(DXTableModel *)tableModel
                      options:(NSDictionary *)options;

@end
