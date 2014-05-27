//
//  DXTableRow.h
//  Pieces
//
//  Created by Alexander Ignatenko on 22/05/14.
//  Copyright (c) 2014 Alexander Ignatenko. All rights reserved.
//

#import "DXTableItem.h"

//extern NSString *const DXTableRowIdentifierKey; //?
extern NSString *const DXTableRowClassKey;
extern NSString *const DXTableRowNibKey;

extern NSString *const DXTableRowWillSelectActionKey;
extern NSString *const DXTableRowDidSelectActionKey;

@interface DXTableRow : DXTableItem

@property (nonatomic, readonly) NSInteger repeatCount;

@end
