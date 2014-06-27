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
extern NSString *const DXTableHeaderKey; // Header title. Accepts string or keypath.
extern NSString *const DXTableFooterKey; // Footer title. Accepts string or keypath
extern NSString *const DXTableHeightKey; // Accepts wrapped in NSNumber float or keypath.
extern NSString *const DXTableActiveKey; // aka Enabled or Visible. Accepts wrapper in NSNumber bool or keypath.
extern NSString *const DXTableRepeatableKey; // aka Template. Accepts wrapper in NSNumber bool or keypath.
extern NSString *const DXTableArrayKey; // aka List or Collection. Accepts keypath pointed to ordered collection.
extern NSString *const DXTableBindingsKey; // aka Attributes or Data or Properties or Keypaths. Accepts dictionary.
extern NSString *const DXTableActionsKey; // Accepts dictionary
extern NSString *const DXTableTargetKey; // Accepts any object
extern NSString *const DXTableUpdatesKey; // aka Update Upon Change. Accepts array of any DXTable..Keys or keypaths

@interface DXTableItem : NSObject

+ (NSPredicate *)predicateForActiveItems;

@property (nonatomic, getter=isActive) BOOL active;

@property (nonatomic, weak, readonly) id dataContext;

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
    `@.name` - keypath is being resolved against `DXTableArrayKey` value (is used with repeatable rows)
 */
NSString *DXTableParseKeyValue(id value);
