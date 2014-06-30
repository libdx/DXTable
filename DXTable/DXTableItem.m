//
//  DXTableItem.m
//  Pieces
//
//  Created by Alexander Ignatenko on 22/05/14.
//  Copyright (c) 2014 Alexander Ignatenko. All rights reserved.
//

#import "DXTableItem.h"

@interface DXTableItem ()

@property (nonatomic, copy) NSDictionary *options;

@end

@implementation DXTableItem

+ (NSPredicate *)predicateForActiveItems
{
    return [NSPredicate predicateWithFormat:@"isActive = YES"];
}

- (instancetype)initWithOptions:(NSDictionary *)options
{
    self = [super init];
    if (self) {
        self.options = options;
        self.active = YES;
        if ([options[DXTableActiveKey] isKindOfClass:[NSNumber class]]) {
            self.active = [options[DXTableActiveKey] boolValue];
        }
    }
    return self;
}

- (id)objectForKeyedSubscript:(id)key
{
    return self.options[key];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; %@>",
            NSStringFromClass([self class]), self, self.options];
}

@end

NSString *const DXTableNameKey          = @"name";
NSString *const DXTableHeaderKey        = @"header";
NSString *const DXTableFooterKey        = @"footer";
NSString *const DXTableHeightKey        = @"height";
NSString *const DXTableActiveKey        = @"active";
NSString *const DXTableRepeatableKey    = @"repeatable";
NSString *const DXTableArrayKey         = @"array";
NSString *const DXTableBindingsKey      = @"bindings";
NSString *const DXTableModeKey          = @"mode";
NSString *const DXTableActionsKey       = @"actions";
NSString *const DXTableTargetKey        = @"target";
NSString *const DXTableUpdatesKey       = @"updates";
NSString *const DXTableClassKey         = @"class";
NSString *const DXTableNibKey           = @"nib";

NSString *const DXTableToViewMode   = @"ToView";
NSString *const DXTableFromViewMode = @"FromView";
