//
//  DXTableSection.m
//  Pieces
//
//  Created by Alexander Ignatenko on 22/05/14.
//  Copyright (c) 2014 Alexander Ignatenko. All rights reserved.
//

#import "DXTableSection.h"
#import "DXTableRow.h"
#import "DXTableModel.h"

@interface DXTableSection ()

@property (nonatomic, weak) DXTableModel *tableModel;

@end

@implementation DXTableSection

- (instancetype)initWithOptions:(NSDictionary *)options
{
    NSAssert(NO, @"Use designated initializer: -initWithModel:options:");
    return nil;
}

- (instancetype)initWithModel:(DXTableModel *)tableModel
                      options:(NSDictionary *)options
{
    self = [super initWithOptions:options];
    if (self) {
        self.tableModel = tableModel;
    }
    return self;
}


- (id)dataContext
{
    return self.tableModel.dataContext;
}

@synthesize allRows = _allRows;
- (NSArray *)allRows
{
    if (_allRows == nil) {
        NSMutableArray *rows = [NSMutableArray array];
        for (NSDictionary *options in self[DXTableRowsKey]) {
            [rows addObject:[[DXTableRow alloc]
                             initWithSection:self options:options]];
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
