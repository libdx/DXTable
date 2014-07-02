//
//  DXTableItem.h
//  Pieces
//
//  Created by Alexander Ignatenko on 22/05/14.
//  Copyright (c) 2014 Alexander Ignatenko. All rights reserved.
//

#import <Foundation/Foundation.h>

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

// Accepts wrapped in NSNumber bool or keypath.
extern NSString *const DXTableRepeatableKey;

// Accepts wrapped in NSNumber bool or keypath. Mapping templated rows against mutable array is not supported!
extern NSString *const DXTableTemplateKey;

// aka List or Collection. Accepts keypath pointed to ordered collection.
extern NSString *const DXTableArrayKey;

// aka Attributes or Data or Properties or Keypaths. Accepts dictionary. For header, footer and repeatable rows supports one-way (to view) bindings only.
extern NSString *const DXTableBindingsKey;

// bindings mode. Can be either: DXTableToViewMode, DXTableFromViewMode
extern NSString *const DXTableModeKey;

// Accepts string which represents keypath. Depending on context keypath can be either plain or starts with `@' prefix.
extern NSString *const DXTableKeypathKey;

// Accepts dictionary of strings which are represent predefined actions (like DXTableRowDidSelectActionKey)
extern NSString *const DXTableActionsKey;

// Accepts any object. Target should responds to defined actions in table model markup.
extern NSString *const DXTableTargetKey;

// aka Update Upon Change. Accepts array of any DXTable..Keys or keypaths. All these keypaths must be observable. Changes of this properties triggers call of reloadRowAtIndexPath:… method.
extern NSString *const DXTableUpdatesKey;

// Binding modes

// Mode for updating view on bound data context property change
extern NSString *const DXTableToViewMode;

// Mode for updating data context on bound view property change
extern NSString *const DXTableFromViewMode;

@interface DXTableItem : NSObject

+ (NSPredicate *)predicateForActiveItems;

@property (nonatomic, getter=isActive) BOOL active;

@property (nonatomic, weak, readonly) id dataContext;

- (instancetype)initWithOptions:(NSDictionary *)options;

- (id)objectForKeyedSubscript:(id)key;

@end
