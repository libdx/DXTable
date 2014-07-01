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
#import "DXTableParse.h"

@interface DXTableSection ()

@property (nonatomic, weak) DXTableModel *tableModel;

@end

@implementation DXTableSection

+ (NSArray *)sectionWithModel:(DXTableModel *)tableModel
                      options:(NSDictionary *)options
{
    NSMutableArray *sections = [NSMutableArray array];
    BOOL isTemplate = [options[DXTableTemplateKey] boolValue];
    if (isTemplate) {
        NSString *arrayKeypath = DXTableParseKeyValue(options[DXTableArrayKey]);
        NSArray *array = arrayKeypath ? [tableModel.dataContext valueForKeyPath:arrayKeypath] : nil;
        NSUInteger count = array ? array.count : 1;
        for (int i = 0; i < count; ++i) {
            DXTableSection *section = [[DXTableSection alloc] initWithModel:tableModel options:options];
            [sections addObject:section];
        }
    } else {
        DXTableSection *section = [[DXTableSection alloc] initWithModel:tableModel options:options];
        [sections addObject:section];
    }
    return sections.copy;
}

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
    id dataContext;
    if (self.isTemplated) {
        NSString *arrayKeypath = DXTableParseKeyValue(self[DXTableArrayKey]);
        if (arrayKeypath) {
            NSArray *array = [self.tableModel.dataContext valueForKeyPath:arrayKeypath];
            NSUInteger index = [self.tableModel.activeSections indexOfObject:self];
            dataContext = array[index];
        }
    }
    dataContext = dataContext ?: self.tableModel.dataContext;
    return dataContext;
}

@synthesize allRows = _allRows;
- (NSArray *)allRows
{
    if (_allRows == nil) {
        NSMutableArray *rows = [NSMutableArray array];
        for (NSDictionary *options in self[DXTableRowsKey]) {
            [rows addObjectsFromArray:
             [DXTableRow rowsWithSection:self options:options]];
        }
        _allRows = rows.copy;
    }
    return _allRows;
}

- (DXTableRowArray *)activeRows
{
    return [[DXTableRowArray alloc] initWithArray:
            [self.allRows filteredArrayUsingPredicate:
             [DXTableItem predicateForActiveItems]]];
}

- (BOOL)isTemplated
{
    return [self[DXTableTemplateKey] boolValue];
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
    NSString *title;
    NSString *keypath = DXTableParseKeyValue(self[DXTableHeaderKey]);
    if (keypath) {
        title = [self.dataContext valueForKeyPath:keypath];
    } else {
        title = [self[DXTableHeaderKey] isKindOfClass:[NSString class]] ? self[DXTableHeaderKey] : nil;
    }
    return title;
}

- (NSString *)footerTitle
{
    NSString *title;
    NSString *keypath = DXTableParseKeyValue(self[DXTableFooterKey]);
    if (keypath) {
        title = [self.dataContext valueForKeyPath:keypath];
    } else {
        title = [self[DXTableFooterKey] isKindOfClass:[NSString class]] ? self[DXTableFooterKey] : nil;
    }
    return title;
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
