//
//  DXTableRow.m
//  Pieces
//
//  Created by Alexander Ignatenko on 22/05/14.
//  Copyright (c) 2014 Alexander Ignatenko. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DXTableRow.h"
#import "DXTableSection.h"
#import "DXTableRowArray.h"
#import "DXTableParse.h"

@interface DXTableRow ()

@property (nonatomic, weak) DXTableSection *section;

@end

@implementation DXTableRow

+ (NSArray *)rowsWithSection:(DXTableSection *)section
                     options:(NSDictionary *)options
{
    NSMutableArray *rows = [NSMutableArray array];
    BOOL isTemplate = [options[DXTableTemplateKey] boolValue];
    if (isTemplate) {
        NSString *arrayKeypath = DXTableParseKeyValue(options[DXTableArrayKey]);
        NSArray *array = arrayKeypath ? [section.dataContext valueForKeyPath:arrayKeypath] : nil;
        NSUInteger count = array ? array.count : 1;
        for (int i = 0; i < count; ++i) {
            DXTableRow *row = [[DXTableRow alloc] initWithSection:section options:options];
            [rows addObject:row];
        }
    } else {
        DXTableRow *row = [[DXTableRow alloc] initWithSection:section options:options];
        [rows addObject:row];
    }
    return rows.copy;
}

- (instancetype)initWithOptions:(NSDictionary *)options
{
    NSAssert(NO, @"Use designated initializer: -initWithSection:options:");
    return nil;
}

- (instancetype)initWithSection:(DXTableSection *)section
                        options:(NSDictionary *)options
{
    self = [super initWithOptions:options];
    if (self) {
        self.section = section;
    }
    return self;
}

- (id)dataContext
{
    NSAssert(NO == (self.isTemplated && self.isRepeatable), @"Row cannot be template and repeatable simultaneously");
    id dataContext;
    if (self.isTemplated) {
        NSString *arrayKeypath = DXTableParseKeyValue(self[DXTableArrayKey]);
        if (arrayKeypath) {
            NSArray *array = [self.section.dataContext valueForKeyPath:arrayKeypath];
            // if it's not repeatable row (and it shoudn't) there will be only one index.
            NSUInteger index = [self.section.activeRows indexesOfRow:self].firstIndex;
            dataContext = array[index];
        }
    }
    dataContext = dataContext ?: self.section.dataContext;
    return dataContext;
}

- (id)target
{
    return self[DXTableTargetKey];
}

- (BOOL)isRepeatable
{
    return [self[DXTableRepeatableKey] boolValue];
}

- (BOOL)isTemplated
{
    return [self[DXTableTemplateKey] boolValue];
}

- (CGFloat)height
{
    CGFloat height = UITableViewAutomaticDimension;
    if ([self[DXTableHeightKey] isKindOfClass:[NSNumber class]]) {
        height = [self[DXTableHeightKey] doubleValue];
    } else {
        NSString *heightKeypath = DXTableParseKeyValue(self[DXTableHeightKey]);
        if (heightKeypath) {
            height = [[self.dataContext valueForKeyPath:heightKeypath] doubleValue];
        }
    }
    return height;
}

- (NSInteger)repeatCount
{
    NSString *arrayKeypath = DXTableParseKeyValue(self[DXTableArrayKey]);
    return self.isRepeatable == YES ?
    [[self.dataContext valueForKeyPath:arrayKeypath] count] : 1;
}

- (BOOL)isEditable
{
    BOOL editable = self.isRepeatable || self.isTemplated;
    if ([self[DXTableRowEditableKey] isKindOfClass:[NSNumber class]]) {
        editable = [self[DXTableRowEditableKey] boolValue];
    } else {
        NSString *keypath = DXTableParseKeyValue(self[DXTableRowEditableKey]);
        if (keypath) {
            editable = [[self.dataContext valueForKeyPath:keypath] boolValue];
        }
    }
    return editable;
}

- (NSInteger)editingStyle
{
    NSInteger style = self.isRepeatable || self.isTemplated ?
    UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleNone;
    if ([self[DXTableRowEditingStyleKey] isKindOfClass:[NSNumber class]]) {
        style = [self[DXTableRowEditingStyleKey] integerValue];
    } else {
        NSString *keypath = DXTableParseKeyValue(self[DXTableRowEditingStyleKey]);
        if (keypath) {
            style = [[self.dataContext valueForKeyPath:keypath] integerValue];
        }
    }
    return style;
}

@end

NSString *const DXTableRowEditableKey = @"editable";
NSString *const DXTableRowEditingStyleKey = @"editingStyle";

NSString *const DXTableRowWillSelectActionKey = @"willSelect";
NSString *const DXTableRowDidSelectActionKey = @"didSelect";
NSString *const DXTableRowCommitInsertActionKey = @"commitInsert";
NSString *const DXTableRowCommitDeleteActionKey = @"commitDelete";
