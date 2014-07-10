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

- (NSDictionary *)actions
{
    NSDictionary *rawActions = self[DXTableActionsKey];

    // normalize dictionary of actions to make all values looks like @{DXTableSelectorKey: @"...", DXTableEnabledKey: @..}
    NSMutableDictionary *allActions = [NSMutableDictionary dictionary];
    for (NSString *action in rawActions) {
        id value = rawActions[action];
        NSString *selector;
        NSString *enabled;
        if ([value isKindOfClass:[NSNumber class]]) {
            // bool value. treat it like value for DXTableEnabledKey
            enabled = value;
        } else if ([value isKindOfClass:[NSString class]]) {
            // string value. treat it like value for DXTableSelectorKey
            selector = value;
        } else if ([value isKindOfClass:[NSDictionary class]]) {
            // dict value.
            selector = value[DXTableSelectorKey];
            enabled = value[DXTableEnabledKey];
        }
        allActions[action] = @{DXTableSelectorKey: selector, DXTableEnabledKey: enabled};
    }

    // filter enabled actions. set selectors as a values of dictionary.
    NSMutableDictionary *enabledActions = [NSMutableDictionary dictionary];
    for (NSString *action in allActions) {
        NSDictionary *value = allActions[action];
        if ([value[DXTableEnabledKey] boolValue]) {
            enabledActions[action] = value[DXTableSelectorKey];
        }
    }
    return enabledActions;
}

@end

NSString *const DXTableNameKey          = @"name";
NSString *const DXTableHeaderKey        = @"header";
NSString *const DXTableFooterKey        = @"footer";
NSString *const DXTableHeightKey        = @"height";
NSString *const DXTableActiveKey        = @"active";
NSString *const DXTableRepeatableKey    = @"repeatable";
NSString *const DXTableTemplateKey      = @"template";
NSString *const DXTableArrayKey         = @"array";
NSString *const DXTableBindingsKey      = @"bindings";
NSString *const DXTableModeKey          = @"mode";
NSString *const DXTableKeypathKey       = @"keypath";
NSString *const DXTableActionsKey       = @"actions";
NSString *const DXTableSelectorKey      = @"selector";
NSString *const DXTableEnabledKey       = @"enabled";
NSString *const DXTableTargetKey        = @"target";
NSString *const DXTableUpdatesKey       = @"updates";
NSString *const DXTableClassKey         = @"class";
NSString *const DXTableNibKey           = @"nib";

NSString *const DXTableToViewMode   = @"ToView";
NSString *const DXTableFromViewMode = @"FromView";
