//
//  DXTableItem.h
//  Pieces
//
//  Created by Alexander Ignatenko on 22/05/14.
//  Copyright (c) 2014 Alexander Ignatenko. All rights reserved.
//

#import <Foundation/Foundation.h>

//#define DXKeyPath(sel) NSStringFromSelector(@selector(sel)) //?

// aka Unique Identifier. Unique accross concrete item type name. For rows and header/footer items is used as reuse identifier.
extern NSString *const DXTableNameKey;

// Header title or view. Accepts string, keypath or dictionary with item options.
extern NSString *const DXTableHeaderKey;

// Footer title or view. Accepts string, keypath or dictionary with item options.
extern NSString *const DXTableFooterKey;

// Accepts wrapped in NSNumber float or keypath.
extern NSString *const DXTableHeightKey;

// Accepts class name as a string or class instance of cell or header/footer view
extern NSString *const DXTableClassKey;

// Accepts nib name as a string or nib instance of cell or header/footer view
extern NSString *const DXTableNibKey;

// aka Enabled or Visible. Accepts wrapped in NSNumber bool or keypath.
extern NSString *const DXTableActiveKey;

// aka Template. Accepts wrapped in NSNumber bool or keypath.
extern NSString *const DXTableRepeatableKey;

// aka List or Collection. Accepts keypath pointed to ordered collection.
extern NSString *const DXTableArrayKey;

// aka Attributes or Data or Properties or Keypaths. Accepts dictionary. For header, footer and repeatable rows supports one-way bindings only.
extern NSString *const DXTableBindingsKey;

// Accepts dictionary of strings which are represent predefined actions (like DXTableRowDidSelectActionKey)
extern NSString *const DXTableActionsKey;

// Accepts any object. Target should responds to defined actions in table model markup.
extern NSString *const DXTableTargetKey;

// aka Update Upon Change. Accepts array of any DXTable..Keys or keypaths. All these keypaths must be observable. Changes of this properties triggers call of reloadRowAtIndexPath:… method.
extern NSString *const DXTableUpdatesKey;

@interface DXTableItem : NSObject

+ (NSPredicate *)predicateForActiveItems;

@property (nonatomic, getter=isActive) BOOL active;

@property (nonatomic, weak, readonly) id dataContext;

- (instancetype)initWithOptions:(NSDictionary *)options;

- (id)objectForKeyedSubscript:(id)key;

@end


// TODO: move following functions to bindings (table model bindings) or utils module (?)
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
