//
//  DXTableModel.h
//  Pieces
//
//  Created by Alexander Ignatenko on 22/05/14.
//  Copyright (c) 2014 Alexander Ignatenko. All rights reserved.
//

#import "DXTableItem.h"

extern NSString *const DXTableSectionsKey;

@class DXTableRow;

@interface DXTableModel : DXTableItem

@property (nonatomic, weak) id dataContext;

/**
 Sections including disabled (isEnabled == NO).
 */
@property (nonatomic, readonly) NSArray *allSections;

/**
 Returns flatten array of all rows from all sections
 */
@property (nonatomic, readonly) NSArray *allRows;

/**
 Enabled sections.
 */
@property (nonatomic, readonly) NSArray *activeSections;

/**
 Returns index path object among enabled rows.
 Given `row` must be enabled.
 */
- (NSIndexPath *)indexPathOfRow:(DXTableRow *)row;

/**
 Returns index path object among enabled rows if given row were enabled.
 */
- (NSIndexPath *)indexPathOfRowIfWereEnabled:(DXTableRow *)row;

@end
