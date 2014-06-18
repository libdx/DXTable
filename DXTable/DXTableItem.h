//
//  DXTableItem.h
//  Pieces
//
//  Created by Alexander Ignatenko on 22/05/14.
//  Copyright (c) 2014 Alexander Ignatenko. All rights reserved.
//

#import <Foundation/Foundation.h>

//#define DXKeyPath(sel) NSStringFromSelector(@selector(sel)) //?

extern NSString *const DXTableNameKey;
extern NSString *const DXTableTitleKey;
extern NSString *const DXTableHeightKey;
extern NSString *const DXTableActiveKey; // aka Enabled or Visible
extern NSString *const DXTableRepeatableKey; // aka Template
extern NSString *const DXTableListKey; // aka Array or Collection
extern NSString *const DXTableEditingStyleKey;
extern NSString *const DXTableBindingsKey; // aka Attributes or Data or Properties or Keypaths
extern NSString *const DXTableActionsKey;
extern NSString *const DXTableTargetKey;

// TODO:
// add key like needsUpdate to trigger reloadRowAt... action
// return list of keys which chaning values are trigger to call relaodRowAt..
// for instance when height of cell was changed we need to call reloadRowAt...

@interface DXTableItem : NSObject

+ (NSPredicate *)predicateForActiveItems;

@property (nonatomic, getter=isActive) BOOL active;

@property (nonatomic, readonly) id dataContext;

- (instancetype)initWithOptions:(NSDictionary *)options;

- (id)objectForKeyedSubscript:(id)key;

@end


// TODO: move following functions to bindings (table model bindings) or utils module
/**
 Converts DXTable format of keypath to KVC-compliant keypath.
 Returns `nil` if `object` is nil, not a string object or has wrong format.
 Accepted keypath format is any KVC-compliant keypath with `@` or `@.` prefix.
 Examples:
    `@items` - keypath comprises with one key
    `@items.name` - keypath comprises with couple keys
    `@.name` - keypath is being resolved against `DXTableListKey` value (is used in repeatable rows)
 */
NSString *DXTableParseKeyValue(id value);
