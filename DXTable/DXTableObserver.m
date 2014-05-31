//
//  DXTableObserver.m
//  Pieces
//
//  Created by Alexander Ignatenko on 27/05/14.
//  Copyright (c) 2014 Alexander Ignatenko. All rights reserved.
//

#import "DXTableObserver.h"
#import "DXTable.h"
#import "DXBindings.h"
#import "FBKVOController.h"
#import <objc/runtime.h>

@interface DXTableObserver ()

@property (nonatomic) FBKVOController *kvoController;

@end

static id nilIfNull(id object)
{
    return [object isKindOfClass:[NSNull class]] ? nil : object;
}

@implementation DXTableObserver

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.kvoController = [FBKVOController controllerWithObserver:self];
    }
    return self;
}

- (void)observeCollection:(id)collectionOrEnumerator
                  keyPath:(NSString *)keyPath
                  options:(NSKeyValueObservingOptions)options
                    block:(FBKVONotificationBlock)block
{
    for (id object in collectionOrEnumerator) {
        [self.kvoController observe:object keyPath:keyPath options:options block:block];
    }
}

- (void)startObservingTableModel:(DXTableModel *)tableModel inDataContext:(id)dataContext
{
    // subscribe to each row "enabled" keypath
    [self observeCollection:tableModel.allRows keyPath:@"enabled" options:NSKeyValueObservingOptionNew block:
     ^(DXTableObserver *observer, DXTableRow *row, NSDictionary *change) {
         if ([observer.delegate respondsToSelector:@selector(tableObserver:
                                                             didObserveRowChange:
                                                             atIndexPaths:
                                                             forChangeType:
                                                             newIndexPaths:)])
         {
             BOOL isEnabled = [change[NSKeyValueChangeNewKey] boolValue];
             NSArray *indexPaths = isEnabled ?
             [tableModel indexPathsOfRow:row] : [tableModel indexPathsOfRowIfWereEnabled:row];
             DXTableObserverChangeType changeType = isEnabled ?
             DXTableObserverChangeInsert : DXTableObserverChangeDelete;
             [observer.delegate tableObserver:self
                          didObserveRowChange:row
                                 atIndexPaths:indexPaths
                                forChangeType:changeType
                                newIndexPaths:nil];
         }
     }];

    // subscribe to each section "enabled" keypath
    // TODO

    // subscribe to keypaths from rows dictionaries
    for (DXTableSection *section in tableModel.allSections) {
        for (DXTableRow *row in section.allRows) {
            id enabledValue = row[DXTableEnabledKey];
            NSString *keypath = DXTableParseKeyValue(enabledValue);
            if (keypath) {
                NSKeyValueObservingOptions options =
                NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew;
                [self.kvoController observe:dataContext keyPath:keypath options:options block:
                 ^(id observer, id object, NSDictionary *change) {
                     row.enabled = [change[NSKeyValueChangeNewKey] boolValue];
                 }];
            }
        }
    }

    // subscribe to repeatable rows to insert/delete cells
    for (DXTableRow *row in tableModel.allRows) {
        if (row.isRepeatable) {
            NSString *listKeypath = DXTableParseKeyValue(row[DXTableListKey]);
            NSKeyValueObservingOptions options = /*NSKeyValueObservingOptionInitial |*/
            NSKeyValueObservingOptionNew;
            [self.kvoController observe:dataContext keyPath:listKeypath options:options block:
             ^(DXTableObserver *observer, id dataContext, NSDictionary *change) {
                 if ([observer.delegate respondsToSelector:@selector(tableObserver:
                                                                     didObserveRowChange:
                                                                     atIndexPaths:
                                                                     forChangeType:
                                                                     newIndexPaths:)])
                 {
                     NSIndexSet *indexes = change[NSKeyValueChangeIndexesKey];
                     NSMutableArray *indexPaths = [NSMutableArray array];
                     NSUInteger index = indexes.firstIndex;
                     while (index != NSNotFound) {
                         NSInteger sectionIndex = [tableModel.activeSections indexOfObject:row.section];
                         NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:sectionIndex];
                         [indexPaths addObject:indexPath];
                         index = [indexes indexGreaterThanIndex:index];
                     }
                     NSInteger kind = [change[NSKeyValueChangeKindKey] integerValue];
                     DXTableObserverChangeType changeType;
                     if (kind == NSKeyValueChangeInsertion) {
                         changeType = DXTableObserverChangeInsert;
                     } else if (kind == NSKeyValueChangeRemoval) {
                         changeType = DXTableObserverChangeDelete;
                     }
                     [observer.delegate tableObserver:observer
                                  didObserveRowChange:row
                                         atIndexPaths:indexPaths
                                        forChangeType:changeType
                                        newIndexPaths:nil];
                 }
             }];
        }
    }
}

- (void)setupBindingsForCell:(UITableViewCell *)cell atRow:(DXTableRow *)row inDataContext:(id)dataContext;
{
    NSDictionary *bindings = row[DXTablePropertiesKey];
    for (NSString *cellKeypath in bindings) { // "textLabel.text": "Hello"
        id value = bindings[cellKeypath];
        NSString *dataKeypath = DXTableParseKeyValue(value);
        if (dataKeypath == nil) {
            // assign `value` directly
            [cell setValue:nilIfNull(value) forKeyPath:cellKeypath];
        } else {
            // `value` is actually a keypath then dealing with bindings

            { // support for repeatable rows
                if (row.isRepeatable) {

                    cell.textLabel.text = @"Repeatable Cell";
                    break; // don't observe repeatable rows for now
//                    NSString *listKeypath = DXTableParseKeyValue(row[DXTableListKey]);
//                    // TODO: check is listKeypath is not nil
//                    dataKeypath = [NSString stringWithFormat:@"%@.%@",
//                                   listKeypath, dataKeypath];
                }
                // FIXME: observe items in array
            }

            // bind model to views
            FBKVOController *cellKvoController = [FBKVOController controllerWithObserver:cell];
            static void *cellKvoControllerKey = &cellKvoControllerKey;
            objc_setAssociatedObject(cell, cellKvoControllerKey, cellKvoController, OBJC_ASSOCIATION_RETAIN);
            NSKeyValueObservingOptions options =
            NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew;
            [cellKvoController observe:dataContext keyPath:dataKeypath options:options block:
             ^(id observer, id object, NSDictionary *change) {
                 id newValue = change[NSKeyValueChangeNewKey];
                 [cell setValue:nilIfNull(newValue) forKeyPath:cellKeypath];
             }];

            // bind views (controls) to model
            // lookup UIControl objects traversing through cellKeypath components
            // "textField.text"
            NSArray *cellKeypathComponents = [cellKeypath componentsSeparatedByString:@"."];
            [cellKeypathComponents enumerateObjectsUsingBlock:
             ^(NSString *component, NSUInteger idx, BOOL *stop) {
                 NSString *leftSideKeypath =
                 [[cellKeypathComponents subarrayWithRange:NSMakeRange(0, idx + 1)]
                  componentsJoinedByString:@"."];
                 id object = [cell valueForKeyPath:leftSideKeypath];
                 if ([object isKindOfClass:[UIControl class]]) {
                     UIControl *control = object;
                     static void *ControlValueTargetKey = &ControlValueTargetKey;
                     DXValueTarget *target = objc_getAssociatedObject(control, ControlValueTargetKey);
                     if (target == nil) {
                         target = [[DXValueTarget alloc] init];
                         [target becomeTargetOfControl:control];
                         objc_setAssociatedObject(control, ControlValueTargetKey, target, OBJC_ASSOCIATION_RETAIN);
                     }
                     [target setValueChanged:^(id value, UIEvent *event) {
                         [dataContext setValue:nilIfNull(value) forKeyPath:dataKeypath];
                     }];
                 }
             }];
        }
    }
}

@end
