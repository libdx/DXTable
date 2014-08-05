//
//  DXTableSection.h
//  Pieces
//
//  Created by Alexander Ignatenko on 22/05/14.
//  Copyright (c) 2014 Alexander Ignatenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

#import "DXTableItem.h"

@class DXTableModel, DXTableRowArray;

extern NSString *const DXTableRowsKey;
extern NSString *const DXTableRowHeightKey;

@interface DXTableSection : DXTableItem

/**
 Returns multiple sections if options contain tempate flag set to YES. Returns one secion in array otherwise.
 */
+ (NSArray *)sectionWithModel:(DXTableModel *)tableModel
                      options:(NSDictionary *)options;

@property (nonatomic, weak, readonly) DXTableModel *tableModel;

@property (nonatomic, readonly, getter=isTemplated) BOOL templated;

@property (nonatomic, readonly) NSArray *allRows;
@property (nonatomic, readonly) DXTableRowArray *activeRows;

@property (nonatomic, readonly) NSString *headerTitle;
@property (nonatomic, readonly) NSString *footerTitle;

@property (nonatomic, readonly) DXTableItem *header;
@property (nonatomic, readonly) DXTableItem *footer;

@property (nonatomic, readonly) CGFloat headerHeight;
@property (nonatomic, readonly) CGFloat footerHeight;

/**
 The height to be used for each row in section.
 Has higher priority over per row height.
 Exists for optimization purpose when need to display long lists (hundred rows or more).
 */
@property (nonatomic, readonly) CGFloat rowHeight;

/// Returns YES when rowHeight is set through options dictionary using DXTableRowHeightKey ("rowHeight") key.
@property (nonatomic, readonly, getter=isRowHeightSet) BOOL rowHeightSet;

- (instancetype)initWithModel:(DXTableModel *)tableModel
                      options:(NSDictionary *)options;

@end
