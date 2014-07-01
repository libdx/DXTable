//
//  DXTableModel.m
//  Pieces
//
//  Created by Alexander Ignatenko on 22/05/14.
//  Copyright (c) 2014 Alexander Ignatenko. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DXTableModel.h"
#import "DXTableSection.h"
#import "DXTableRow.h"
#import "DXTableRowArray.h"

@implementation DXTableModel

- (instancetype)initWithOptions:(NSDictionary *)options
{
    return [self initWithDataContext:nil options:options];
}

- (instancetype)initWithDataContext:(id)dataContext options:(NSDictionary *)options
{
    self = [super initWithOptions:options];
    if (self) {
        _dataContext = dataContext;
    }
    return self;
}

@synthesize dataContext = _dataContext;
- (id)dataContext
{
    if (_dataContext == nil) {
        NSAssert(NO, @"dataContext for the table model %@ has not been setup", self);
    }
    return _dataContext;
}

@synthesize allSections = _allSections;
- (NSArray *)allSections
{
    if (_allSections == nil) {
        NSMutableArray *sections = [NSMutableArray array];
        for (NSDictionary *options in self[DXTableSectionsKey]) {
            [sections addObject:[[DXTableSection alloc]
                                 initWithModel:self options:options]];
        }
        _allSections = sections.copy;
    }
    return _allSections;
}

- (NSArray *)allRows
{
    return [[self.allSections valueForKeyPath:@"allRows"] valueForKeyPath:@"@unionOfArrays.self.self"];
}

- (NSArray *)activeSections
{
    return [self.allSections filteredArrayUsingPredicate:
            [DXTableItem predicateForActiveItems]];
}

- (NSArray *)indexPathsOfRow:(DXTableRow *)row
{
    NSPredicate *containsRow =
    [NSPredicate predicateWithFormat:@"activeRows.array CONTAINS %@", row];

    DXTableSection *section = [self.activeSections
                               filteredArrayUsingPredicate:containsRow].firstObject;

    NSUInteger sectionIndex = [self.activeSections indexOfObject:section];
    NSIndexSet *rowIndexes = [section.activeRows indexesOfRow:row];

    NSMutableArray *indexPaths = [NSMutableArray array];
    NSUInteger rowIndex = [rowIndexes firstIndex];
    while (rowIndex != NSNotFound) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowIndex
                                                    inSection:sectionIndex];
        [indexPaths addObject:indexPath];
        rowIndex = [rowIndexes indexGreaterThanIndex:rowIndex];
    }

    return indexPaths;
}

- (NSArray *)indexPathsOfRowIfWereActive:(DXTableRow *)row
{
    NSPredicate *containsRow =
    [NSPredicate predicateWithFormat:@"allRows CONTAINS %@", row];

    NSPredicate *byRow = [NSPredicate predicateWithFormat:@"SELF = %@", row];
    NSPredicate *byActiveAndGivenRow = [NSCompoundPredicate orPredicateWithSubpredicates:
                                        @[[DXTableItem predicateForActiveItems], byRow]];

    DXTableSection *section = [self.activeSections filteredArrayUsingPredicate:containsRow].firstObject;
    // TODO: handle situation when section disabled
    DXTableRowArray *rows =
    [[DXTableRowArray alloc] initWithArray:
     [section.allRows filteredArrayUsingPredicate:byActiveAndGivenRow]];

    NSUInteger sectionIndex = [self.activeSections indexOfObject:section];
    NSIndexSet *rowIndexes = [rows indexesOfRow:row];

    NSMutableArray *indexPaths = [NSMutableArray array];
    NSUInteger rowIndex = [rowIndexes firstIndex];
    while (rowIndex != NSNotFound) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowIndex
                                                    inSection:sectionIndex];
        [indexPaths addObject:indexPath];
        rowIndex = [rowIndexes indexGreaterThanIndex:rowIndex];
    }

    return indexPaths;
}

@end

NSString *const DXTableSectionsKey = @"sections";
NSString *const DXTableControlsKey = @"controls";
NSString *const DXTableControlEvents = @"events";
