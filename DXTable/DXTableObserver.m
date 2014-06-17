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
{
    struct {
        unsigned delegateRowChange;
    } _observerFlags;
}

@property (nonatomic) FBKVOController *kvoController;

@end

static id nilIfNull(id object)
{
    return [object isKindOfClass:[NSNull class]] ? nil : object;
}

static void addObjectIfNotNil(NSMutableArray *array, id object)
{
    if (object) {
        [array addObject:object];
    }
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

- (void)setDelegate:(id<DXTableObserverDelegate>)delegate
{
    if (_delegate != delegate) {
        _delegate = delegate;
        if ([_delegate respondsToSelector:@selector(tableObserver:didObserveRowChange:atIndexPaths:forChangeType:newIndexPaths:)])
        {
            _observerFlags.delegateRowChange = true;
        }
    }
}

- (DXKVOInfo *)infoForRowActiveKeypath:(DXTableRow *)row
                        fromTableModel:(DXTableModel *)tableModel
{
    DXKVOInfo *info = [[DXKVOInfo alloc] init];
    info.object = row;
    info.keypath = @"enabled";
    info.options = NSKeyValueObservingOptionNew;
    info.block = ^(DXTableObserver *observer, DXTableRow *row, NSDictionary *change) {
        BOOL isEnabled = [change[NSKeyValueChangeNewKey] boolValue];

        NSArray *indexPaths = isEnabled ?
        [tableModel indexPathsOfRow:row] : [tableModel indexPathsOfRowIfWereEnabled:row];

        DXTableObserverChangeType changeType = isEnabled ?
        DXTableObserverChangeInsert : DXTableObserverChangeDelete;

        if (_observerFlags.delegateRowChange) {
            [observer.delegate tableObserver:self
                         didObserveRowChange:row
                                atIndexPaths:indexPaths
                               forChangeType:changeType
                               newIndexPaths:nil];
        }
    };
    return info;
}

- (DXKVOInfo *)infoToTriggerRowProperties:(DXTableRow *)row inDataContext:(id)dataContext
{
    id enabledValue = row[DXTableEnabledKey];
    NSString *keypath = DXTableParseKeyValue(enabledValue);
    DXKVOInfo *info;
    if (keypath) {
        info = [[DXKVOInfo alloc] init];
        info.object = dataContext;
        info.keypath = DXTableParseKeyValue(enabledValue);
        info.options = NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew;
        info.block = ^(id observer, id dataContext, NSDictionary *change) {
            row.enabled = [change[NSKeyValueChangeNewKey] boolValue];
        };
    }
    return info;
}

- (DXKVOInfo *)infoForRepeatableRow:(DXTableRow *)row
                     fromTableModel:(DXTableModel *)tableModel
                      inDataContext:(id)dataContext
{
    DXKVOInfo *info;
    if (row.isRepeatable) {
        info = [[DXKVOInfo alloc] init];
        info.object = dataContext;
        info.options = NSKeyValueObservingOptionNew;
        info.keypath = DXTableParseKeyValue(row[DXTableListKey]);
        info.block = ^(DXTableObserver *observer, id dataContext, NSDictionary *change) {
            if (!_observerFlags.delegateRowChange) {
                return;
            }

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
        };
    }
    return info;
}

- (DXKVOInfo *)infoForEachObjectOfRepeatableRow:(DXTableRow *)row
                                 fromTableModel:(DXTableModel *)tableModel
                                  inDataContext:(id)dataContext
{
    DXKVOInfo *info;
    return info;
}

- (DXKVOInfo *)bindInfoFromDataContext:(id)dataContext
                           dataKeypath:(NSString *)dataKeypath
                                toView:(UIView *)view
                           viewKeypath:(NSString *)viewKeypath
{
    // bind info from model to view
    DXKVOInfo *info = [[DXKVOInfo alloc] init];
    info.object = dataContext;
    info.keypath = dataKeypath;
    info.options = NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew;
    info.block = ^(id observer, id object, NSDictionary *change) {
        id newValue = change[NSKeyValueChangeNewKey];
        [view setValue:nilIfNull(newValue) forKeyPath:viewKeypath];
    };
    return info;
}

- (DXKVOInfo *)bindInfoFromView:(UIView *)view
                    viewKeypath:(NSString *)viewKeypath
                        toDataContext:(id)dataContext
                    dataKeypath:(NSString *)dataKeypath
{
    return nil;
}

- (FBKVOController *)kvoControllerForObject:(id)object
{
    static void *ObjectKvoControllerKey = &ObjectKvoControllerKey;
    // FIXME: leaks!
    FBKVOController *kvoController;// = objc_getAssociatedObject(object, ObjectKvoControllerKey);
    if (kvoController == nil) {
        kvoController = [FBKVOController controllerWithObserver:object];
        objc_setAssociatedObject(object, ObjectKvoControllerKey, kvoController, OBJC_ASSOCIATION_RETAIN);
    }
    return kvoController;
}

- (DXValueTarget *)valueTargetForControl:(UIControl *)control
{
    static void *ControlValueTargetKey = &ControlValueTargetKey;
    DXValueTarget *target = objc_getAssociatedObject(control, ControlValueTargetKey);
    if (target == nil) {
        target = [[DXValueTarget alloc] init];
        [target becomeTargetOfControl:control];
        objc_setAssociatedObject(control, ControlValueTargetKey, target, OBJC_ASSOCIATION_RETAIN);
    }
    return target;
}

- (void)observeWithInfo:(DXKVOInfo *)info
{
    if (info.type == DXKVOTypeObject) {
        [self observeWithInfo:info usingKVOController:self.kvoController];
    }
}

- (void)observeWithInfo:(DXKVOInfo *)info usingKVOController:(FBKVOController *)kvoController
{
    [kvoController observe:info.object keyPath:info.keypath options:info.options block:info.block];
}

- (void)startObservingTableModel:(DXTableModel *)tableModel inDataContext:(id)dataContext
{
    NSMutableArray *infos = [NSMutableArray array];
    for (DXTableSection *section in tableModel.allSections) {
        for (DXTableRow *row in section.allRows) {
            addObjectIfNotNil(infos, [self infoForRowActiveKeypath:row
                                                    fromTableModel:tableModel]);
            addObjectIfNotNil(infos, [self infoToTriggerRowProperties:row
                                                        inDataContext:dataContext]);
            addObjectIfNotNil(infos, [self infoForRepeatableRow:row
                                                 fromTableModel:tableModel
                                                  inDataContext:dataContext]);
            // subscribe to each section "enabled" keypath
            // TODO
        }
    }

    for (DXKVOInfo *info in infos) {
        [self observeWithInfo:info];
    }
}

- (void)setupBindingsForCell:(UITableViewCell *)cell row:(DXTableRow *)row atIndexPath:(NSIndexPath *)indexPath inDataContext:(id)dataContext
{
    NSDictionary *bindings = row[DXTablePropertiesKey];
    for (NSString *cellKeypath in bindings) { // "textLabel.text": "Hello"
        id value = bindings[cellKeypath];
        NSString *dataKeypath = DXTableParseKeyValue(value);
        if (dataKeypath == nil) {
            // assign `value` directly
            [cell setValue:nilIfNull(value) forKeyPath:cellKeypath];
        } else {
            // `value` is actually a keypath so deal with bindings

            NSMutableArray *modelToViewBindings = [NSMutableArray array];
            // bind model to views
            if (row.isRepeatable) {
                // support for repeatable rows

                NSString *listKeypath = DXTableParseKeyValue(row[DXTableListKey]);
                // stupid way to observe objects in array
                NSArray *list = [dataContext valueForKeyPath:listKeypath];
                // find first index in section of repeatable row
                NSUInteger firstRowIndex = [row.section.activeRows indexesOfRow:row].firstIndex;
                NSInteger rowIndex = indexPath.row - firstRowIndex;
                id item  = list[rowIndex];

                [modelToViewBindings addObject:
                 [self bindInfoFromDataContext:item
                                   dataKeypath:dataKeypath
                                        toView:cell
                                   viewKeypath:cellKeypath]];
            } else {
                DXKVOInfo *modelToView = [self bindInfoFromDataContext:dataContext
                                                           dataKeypath:dataKeypath
                                                                toView:cell
                                                           viewKeypath:cellKeypath];
                [modelToViewBindings addObject:modelToView];

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
                         DXValueTarget *target = [self valueTargetForControl:control];
                         target.valueChanged = ^(id value, UIEvent *event) {
                             [dataContext setValue:nilIfNull(value) forKeyPath:dataKeypath];
                         };
                     }
                 }];
            }

            FBKVOController *cellKvoController = [self kvoControllerForObject:cell];
            [cellKvoController unobserve:cell];
            for (id info in modelToViewBindings) {
                [self observeWithInfo:info usingKVOController:cellKvoController];
            }
        }
    }
}

@end
