//
//  DXTableRow.m
//  Pieces
//
//  Created by Alexander Ignatenko on 22/05/14.
//  Copyright (c) 2014 Alexander Ignatenko. All rights reserved.
//

#import "DXTableRow.h"

@implementation DXTableRow

- (NSInteger)repeatCount
{
    return [self[DXTableRepeatableKey] boolValue] == NO ? 1 : 0/* ?? */;
}

@end

NSString *const DXTableRowIdentifierKey = @"id";
NSString *const DXTableRowClassKey = @"class";
NSString *const DXTableRowNibKey = @"nib";

NSString *const DXTableRowWillSelectActionKey = @"willSelect";
NSString *const DXTableRowDidSelectActionKey = @"didSelect";
