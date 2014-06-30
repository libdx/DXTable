//
//  DXTableModel.h
//  Pieces
//
//  Created by Alexander Ignatenko on 22/05/14.
//  Copyright (c) 2014 Alexander Ignatenko. All rights reserved.
//

#import "DXTableItem.h"

extern NSString *const DXTableSectionsKey;
extern NSString *const DXTableControlsKey;
extern NSString *const DXTableControlEvents;

@class DXTableRow;

@interface DXTableModel : DXTableItem

/**
 Sections including disabled (isActive == NO).
 */
@property (nonatomic, readonly) NSArray *allSections;

/**
 Returns flatten array of all rows from all sections
 */
@property (nonatomic, readonly) NSArray *allRows;

/**
 Active sections.
 */
@property (nonatomic, readonly) NSArray *activeSections;

/**
 Designated initializer.
 @param dataContext Data context (a.k.a. data provider) an object which have KVO and KVC compliant properties. Unretained (i.e. refered with weak reference).
 @param options Dictionary object contains model options.
 */
- (instancetype)initWithDataContext:(id)dataContext options:(NSDictionary *)options;

/**
 Returns index path objects among active rows.
 Given `row` must be active.
 */
- (NSArray *)indexPathsOfRow:(DXTableRow *)row;

/**
 Returns index path objects among active rows if given row were active.
 */
- (NSArray *)indexPathsOfRowIfWereActive:(DXTableRow *)row;

@end
