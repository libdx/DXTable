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

@interface DXTableRow ()

@property (nonatomic, weak) DXTableSection *section;

@end

@implementation DXTableRow

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
    return self.section.dataContext;
}

- (id)target
{
    return self[DXTableTargetKey];
}

- (BOOL)isRepeatable
{
    return [self[DXTableRepeatableKey] boolValue];
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
    return [self[DXTableRepeatableKey] boolValue] == YES ?
    [[self.dataContext valueForKeyPath:arrayKeypath] count] : 1;
}

- (BOOL)isEditable
{
    BOOL editable = self.isRepeatable;
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
    NSInteger style = self.isRepeatable ?
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

NSString *const DXTableRowIdentifierKey = @"id";
NSString *const DXTableRowClassKey = @"class";
NSString *const DXTableRowNibKey = @"nib";
NSString *const DXTableRowEditableKey = @"editable";
NSString *const DXTableRowEditingStyleKey = @"editingStyle";

NSString *const DXTableRowWillSelectActionKey = @"willSelect";
NSString *const DXTableRowDidSelectActionKey = @"didSelect";
NSString *const DXTableRowCommitInsertActionKey = @"commitInsert";
NSString *const DXTableRowCommitDeleteActionKey = @"commitDelete";
