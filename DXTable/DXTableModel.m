//
//  DXTableModel.m
//  Pieces
//
//  Created by Alexander Ignatenko on 22/05/14.
//  Copyright (c) 2014 Alexander Ignatenko. All rights reserved.
//

#import "DXTableModel.h"
#import "DXTableSection.h"
#import "DXTableRow.h"

@implementation DXTableModel

@synthesize allSections = _allSections;
- (NSArray *)allSections
{
    if (_allSections == nil) {
        NSMutableArray *sections = [NSMutableArray array];
        for (NSDictionary *options in self[DXTableSectionsKey]) {
            [sections addObject:[[DXTableSection alloc]
                                 initWithOptions:options]];
        }
        _allSections = sections.copy;
    }
    return _allSections;
}

- (NSArray *)activeSections
{
    return [_allSections filteredArrayUsingPredicate:
            [DXTableItem predicateForEnabledItems]];
}

- (NSIndexPath *)indexPathOfRow:(DXTableRow *)row
{
    NSPredicate *containsRow =
    [NSPredicate predicateWithFormat:@"activeRows CONTAINS %@", row];

    DXTableSection *section = [self.activeSections filteredArrayUsingPredicate:containsRow].firstObject;

    NSUInteger sectionIndex = [self.activeSections indexOfObject:section];
    NSUInteger rowIndex = [section.activeRows indexOfObject:row];

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];

    return indexPath;
}

- (NSIndexPath *)indexPathOfRowIfWereEnabled:(DXTableRow *)row
{
    NSPredicate *containsRow =
    [NSPredicate predicateWithFormat:@"allRows CONTAINS %@", row];

    NSPredicate *byRow = [NSPredicate predicateWithFormat:@"SELF = %@", row];
    NSPredicate *byEnabledAndGivenRow = [NSCompoundPredicate orPredicateWithSubpredicates:
                                         @[[DXTableItem predicateForEnabledItems], byRow]];

    DXTableSection *section = [self.activeSections filteredArrayUsingPredicate:containsRow].firstObject;
    // TODO: handle situation when section disabled
    NSArray *rows = [section.allRows filteredArrayUsingPredicate:byEnabledAndGivenRow];

    NSUInteger sectionIndex = [self.activeSections indexOfObject:section];
    NSUInteger rowIndex = [rows indexOfObject:row];

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];

    return indexPath;
}

@end

NSString *const DXTableSectionsKey = @"sections";
