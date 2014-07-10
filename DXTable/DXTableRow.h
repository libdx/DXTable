//
//  DXTableRow.h
//  Pieces
//
//  Created by Alexander Ignatenko on 22/05/14.
//  Copyright (c) 2014 Alexander Ignatenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

#import "DXTableItem.h"

@class DXTableSection;

extern NSString *const DXTableRowEditableKey;
extern NSString *const DXTableRowEditingStyleKey;
extern NSString *const DXTableRowSelectionEnabledKey;

extern NSString *const DXTableRowWillSelectActionKey;
extern NSString *const DXTableRowDidSelectActionKey;
extern NSString *const DXTableRowCommitInsertActionKey;
extern NSString *const DXTableRowCommitDeleteActionKey;

@interface DXTableRow : DXTableItem

/**
 Returns multiple rows if options contain tempate flag set to YES. Returns one row in array otherwise.
 */
+ (NSArray *)rowsWithSection:(DXTableSection *)section
                     options:(NSDictionary *)options;

- (instancetype)initWithSection:(DXTableSection *)section
                        options:(NSDictionary *)options;

@property (nonatomic, weak, readonly) DXTableSection *section;

@property (nonatomic, readonly, getter=isRepeatable) BOOL repeatable;

@property (nonatomic, readonly, getter=isTemplated) BOOL templated;

@property (nonatomic, readonly, getter=isSelectionEnabled) BOOL selectionEnabled;

@property (nonatomic, readonly) id target;

@property (nonatomic, readonly) NSInteger repeatCount;

@property (nonatomic, readonly) CGFloat height;

// for non-repeatable and non-templated default is NO, for repeatable and templated default is YES
@property (nonatomic, readonly, getter=isEditable) BOOL editable;

// for non-repeatable and non-templated default is None, for repeatable and templated default is Delete
@property (nonatomic, readonly) NSInteger editingStyle;

@end
