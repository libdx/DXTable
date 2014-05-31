//
//  DXTableRow.h
//  Pieces
//
//  Created by Alexander Ignatenko on 22/05/14.
//  Copyright (c) 2014 Alexander Ignatenko. All rights reserved.
//

#import "DXTableItem.h"

@class DXTableSection;

//extern NSString *const DXTableRowIdentifierKey; //?
extern NSString *const DXTableRowClassKey;
extern NSString *const DXTableRowNibKey;

extern NSString *const DXTableRowWillSelectActionKey;
extern NSString *const DXTableRowDidSelectActionKey;

@interface DXTableRow : DXTableItem

- (instancetype)initWithSection:(DXTableSection *)section
                        options:(NSDictionary *)options;

@property (nonatomic, weak) DXTableSection *section;

@property (nonatomic, readonly, getter=isRepeatable) BOOL repeatable;

@property (nonatomic, readonly) CGFloat height;
@property (nonatomic, readonly) NSInteger repeatCount;

@end
