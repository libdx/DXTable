//
//  DXTableSection.m
//  Pieces
//
//  Created by Alexander Ignatenko on 22/05/14.
//  Copyright (c) 2014 Alexander Ignatenko. All rights reserved.
//

#import "DXTableSection.h"
#import "DXTableRow.h"

@implementation DXTableSection

@synthesize allRows = _allRows;
- (NSArray *)allRows
{
    if (_allRows == nil) {
        NSMutableArray *rows = [NSMutableArray array];
        for (NSDictionary *options in self[DXTableRowsKey]) {
            [rows addObject:[[DXTableRow alloc]
                             initWithOptions:options]];
        }
        _allRows = rows.copy;
    }
    return _allRows;
}

- (NSArray *)activeRows
{
    return [_allRows filteredArrayUsingPredicate:
            [DXTableItem predicateForEnabledItems]];
}

- (NSInteger)numberOfRows
{
    // Support for repeatable rows
    return [[self.activeRows valueForKeyPath:@"@sum.repeatCount"] integerValue];
}

@end

NSString *const DXTableRowsKey = @"rows";
