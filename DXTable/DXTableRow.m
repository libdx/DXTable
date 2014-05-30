//
//  DXTableRow.m
//  Pieces
//
//  Created by Alexander Ignatenko on 22/05/14.
//  Copyright (c) 2014 Alexander Ignatenko. All rights reserved.
//

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
    NSString *arrayKeypath = DXTableParseKeyValue(self[DXTableListKey]);
    return [self[DXTableRepeatableKey] boolValue] == YES ?
    [[self.dataContext valueForKeyPath:arrayKeypath] integerValue] : 1;
}

@end

NSString *const DXTableRowIdentifierKey = @"id";
NSString *const DXTableRowClassKey = @"class";
NSString *const DXTableRowNibKey = @"nib";

NSString *const DXTableRowWillSelectActionKey = @"willSelect";
NSString *const DXTableRowDidSelectActionKey = @"didSelect";
