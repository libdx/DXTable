//
//  DXTableSection.m
//  Pieces
//
//  Created by Alexander Ignatenko on 22/05/14.
//  Copyright (c) 2014 Alexander Ignatenko. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DXTableSection.h"
#import "DXTableRow.h"
#import "DXTableModel.h"
#import "DXTableRowArray.h"

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

- (DXTableRowArray *)activeRows
{
    return [[DXTableRowArray alloc] initWithArray:
    [_allRows filteredArrayUsingPredicate:
     [DXTableItem predicateForActiveItems]]];
}

@synthesize header = _header;
- (DXTableItem *)header
{
    if (_header == nil) {
        if (self.headerTitle == nil && self[DXTableHeaderKey]) {
            _header = [[DXTableItem alloc] initWithOptions:self[DXTableHeaderKey]];
        }
    }
    return _header;
}

@synthesize footer = _footer;
- (DXTableItem *)footer
{
    if (_footer == nil) {
        if (self.footerTitle == nil && self[DXTableFooterKey]) {
            _footer = [[DXTableItem alloc] initWithOptions:self[DXTableFooterKey]];
        }
    }
    return _footer;
}

- (NSString *)headerTitle
{
    NSString *title = self[DXTableHeaderKey];
    return [title isKindOfClass:[NSString class]] ? title : nil;
}

- (NSString *)footerTitle
{
    NSString *title = self[DXTableFooterKey];
    return [title isKindOfClass:[NSString class]] ? title : nil;
}

- (CGFloat)headerHeight
{
    CGFloat height = UITableViewAutomaticDimension;
    if ([self.header[DXTableHeightKey] isKindOfClass:[NSNumber class]]) {
        height = [self.header[DXTableHeightKey] doubleValue];
    } else {
        NSString *heightKeypath = DXTableParseKeyValue(self.header[DXTableHeightKey]);
        if (heightKeypath) {
            height = [[self.dataContext valueForKeyPath:heightKeypath] doubleValue];
        }
    }
    return height;
}

- (CGFloat)footerHeight
{
    CGFloat height = UITableViewAutomaticDimension;
    if ([self.footer[DXTableHeightKey] isKindOfClass:[NSNumber class]]) {
        height = [self.footer[DXTableHeightKey] doubleValue];
    } else {
        NSString *heightKeypath = DXTableParseKeyValue(self.footer[DXTableHeightKey]);
        if (heightKeypath) {
            height = [[self.dataContext valueForKeyPath:heightKeypath] doubleValue];
        }
    }
    return height;
}

@end

NSString *const DXTableRowsKey = @"rows";
