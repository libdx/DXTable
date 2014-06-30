//
//  DXTableParse.h
//  DXTable
//
//  Created by Alexander Ignatenko on 29/06/14.
//  Copyright (c) 2014 Alexander Ignatenko. All rights reserved.
//

#import <Foundation/Foundation.h>

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

/**
 Returns true if `value` should be bind with default mode (which depends on type of view).
 */
BOOL DXTableParseIsDefaultMode(id value);

/**
 Returns true if `value` is a dictionary and contains DXTableToView (ToView) binding mode option.
 */
BOOL DXTableParseIsToViewMode(id value);

/**
 Returns true if `value` is a dictionary and contains DXTableFromView (FromView) binding mode option.
 */
BOOL DXTableParseIsFromViewMode(id value);
