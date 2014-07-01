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
    info.keypath = @"active";
    info.options = NSKeyValueObservingOptionNew;
    info.block = ^(DXTableObserver *observer, DXTableRow *row, NSDictionary *change) {
        BOOL isActive = [change[NSKeyValueChangeNewKey] boolValue];

        NSArray *indexPaths = isActive ?
        [tableModel indexPathsOfRow:row] : [tableModel indexPathsOfRowIfWereActive:row];

        DXTableObserverChangeType changeType = isActive ?
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

- (DXKVOInfo *)infoToTriggerRowBindings:(DXTableRow *)row
{
    id activeValue = row[DXTableActiveKey];
    NSString *keypath = DXTableParseKeyValue(activeValue);
    DXKVOInfo *info;
    if (keypath) {
        info = [[DXKVOInfo alloc] init];
        info.object = row.dataContext;
        info.keypath = DXTableParseKeyValue(activeValue);
        info.options = NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew;
        info.block = ^(id observer, id dataContext, NSDictionary *change) {
            row.active = [change[NSKeyValueChangeNewKey] boolValue];
        };
    }
    return info;
}

- (DXKVOInfo *)infoForRepeatableRow:(DXTableRow *)row
                     fromTableModel:(DXTableModel *)tableModel
{
    DXKVOInfo *info;
    if (row.isRepeatable) {
        info = [[DXKVOInfo alloc] init];
        info.object = row.dataContext;
        info.options = NSKeyValueObservingOptionNew;
        info.keypath = DXTableParseKeyValue(row[DXTableArrayKey]);
        info.block = ^(DXTableObserver *observer, id dataContext, NSDictionary *change) {
            if (!_observerFlags.delegateRowChange) {
                return;
            }

            NSIndexSet *indexes = change[NSKeyValueChangeIndexesKey];

            NSMutableArray *indexPaths = [NSMutableArray array];
            NSUInteger index = indexes ? indexes.firstIndex : NSNotFound;
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
            } else if (kind == NSKeyValueChangeSetting) {
                changeType = DXTableObserverChangeSetting;
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

// TODO: do the same for sections
- (NSArray *)infosToTriggerUpdateCellForRow:(DXTableRow *)row
                             fromTableModel:(DXTableModel *)tableModel
{
    NSArray *updates = row[DXTableUpdatesKey];
    if (updates == nil) {
        return [NSMutableArray array];
    }
    NSAssert([updates isKindOfClass:[NSArray class]], @"Provide array for %@ key", DXTableUpdatesKey);
    NSMutableArray *infos = [NSMutableArray array];
    for (NSString *key in updates) {
        NSString *keypath = DXTableParseKeyValue(key) ?: DXTableParseKeyValue(row[key]);
        if (keypath) {
            for (NSUInteger index = 0; index < row.repeatCount; ++index) {
                DXKVOInfo *info;
                info = [[DXKVOInfo alloc] init];
                id dataObject = row.dataContext;
                if (row.isRepeatable) {
                    NSString *arrayKeypath = DXTableParseKeyValue(row[DXTableArrayKey]);
                    NSAssert(arrayKeypath, @"repeatable row must contain %@ keypath", DXTableArrayKey);
                    dataObject = [row.dataContext valueForKeyPath:arrayKeypath][index];
                }
                info.object = dataObject;
                info.keypath = keypath;
                info.options = NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew;
                info.block = ^(id observer, id dataObject, NSDictionary *change) {
                    if (_observerFlags.delegateRowChange) {
                        NSArray *indexPaths = [tableModel indexPathsOfRow:row];
                        [self.delegate tableObserver:self
                                 didObserveRowChange:row
                                        atIndexPaths:indexPaths
                                       forChangeType:DXTableObserverChangeUpdate
                                       newIndexPaths:nil];
                    }
                };
                [infos addObject:info];
            }
        }
    }
    return infos.copy;
}

- (DXKVOInfo *)infoForEachObjectOfRepeatableRow:(DXTableRow *)row
                                 fromTableModel:(DXTableModel *)tableModel
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
        id oldValue = [view valueForKeyPath:viewKeypath];
        if (NO == [newValue isEqual:oldValue]) {
            [view setValue:nilIfNull(newValue) forKeyPath:viewKeypath];
        }
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

- (NSDictionary *)metaDataForControlClass:(Class)cls inTableModel:(DXTableModel *)tableModel
{
    NSArray *allMetaData = tableModel[DXTableControlsKey];
    if (allMetaData == nil) {
        return nil;
    }
    NSAssert([allMetaData isKindOfClass:[NSArray class]],
             @"For key DXTableControlsKey (controls) array of dictionaries must be provided");
    NSPredicate *p = [NSPredicate predicateWithFormat:@"%K = %@", DXTableClassKey, cls];
    return [allMetaData filteredArrayUsingPredicate:p].firstObject;
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

- (DXValueTarget *)valueTargetForControl:(UIControl *)control metaData:(NSDictionary *)metaData
{
    static void *ControlValueTargetKey = &ControlValueTargetKey;
    DXValueTarget *target = objc_getAssociatedObject(control, ControlValueTargetKey);
    if (target == nil) {
        target = [[DXValueTarget alloc] init];
        [target becomeTargetOfControl:control];
        objc_setAssociatedObject(control, ControlValueTargetKey, target, OBJC_ASSOCIATION_RETAIN);
    }

    if (metaData) {
        NSAssert(metaData[DXTableClassKey] && metaData[DXTableKeypathKey],
                 @"DXTableClassKey (class) and DXTableKeypathKey (keypath) keys must not be `nil`");
        target.keypathByControlMap =
        @{NSStringFromClass(metaData[DXTableClassKey]) : metaData[DXTableKeypathKey]};
    }

    return target;
}

- (DXViewDelegate *)viewDelegateForTextView:(UITextView *)textView
{
    static void *DelegateKey = &DelegateKey;
    DXViewDelegate *delegate = objc_getAssociatedObject(textView, DelegateKey);
    if (delegate == nil) {
        delegate = [[DXViewDelegate alloc] init];
        textView.delegate = delegate;
        objc_setAssociatedObject(textView, DelegateKey, delegate, OBJC_ASSOCIATION_RETAIN);
    }
    return delegate;
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

- (void)startObservingTableModel:(DXTableModel *)tableModel
{
    NSMutableArray *infos = [NSMutableArray array];
    for (DXTableSection *section in tableModel.allSections) {
        for (DXTableRow *row in section.allRows) {
            addObjectIfNotNil(infos, [self infoForRowActiveKeypath:row
                                                    fromTableModel:tableModel]);
            addObjectIfNotNil(infos, [self infoToTriggerRowBindings:row]);
            addObjectIfNotNil(infos, [self infoForRepeatableRow:row
                                                 fromTableModel:tableModel]);

            [infos addObjectsFromArray:[self infosToTriggerUpdateCellForRow:row
                                                             fromTableModel:tableModel]];
            // subscribe to each section "active" keypath
            // TODO
        }
    }

    for (DXKVOInfo *info in infos) {
        [self observeWithInfo:info];
    }
}

// FIXME: unify this method with setupBindingsForCell:… now it's copy-paste and decouple logic
- (void)setupBindingsForView:(UIView *)view item:(DXTableItem *)item
{
    NSDictionary *bindings = item[DXTableBindingsKey];
    NSMutableArray *modelToViewBindings = [NSMutableArray array];
    for (NSString *viewKeypath in bindings) {
        id value = bindings[viewKeypath];
        NSString *dataKeypath = DXTableParseKeyValue(value);
        if (dataKeypath == nil) {
            // assign `value` directly
            [view setValue:nilIfNull(value) forKeyPath:viewKeypath];
        } else {
            if (DXTableParseIsDefaultMode(value) || DXTableParseIsToViewMode(value)) {
                // `value` is actually a keypath so deal with bindings
                DXKVOInfo *info = [self bindInfoFromDataContext:item.dataContext
                                                    dataKeypath:dataKeypath
                                                         toView:view
                                                    viewKeypath:viewKeypath];
                [modelToViewBindings addObject:info];
            }
        }
    }

    FBKVOController *viewKvoController = [self kvoControllerForObject:view];
    [viewKvoController unobserve:view];
    for (id info in modelToViewBindings) {
        [self observeWithInfo:info usingKVOController:viewKvoController];
    }
}

// FIXME: decouple this mess
- (void)setupBindingsForCell:(UITableViewCell *)cell row:(DXTableRow *)row atIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *bindings = row[DXTableBindingsKey];
    NSMutableArray *modelToViewBindings = [NSMutableArray array];
    for (NSString *cellKeypath in bindings) { // "textLabel.text": "Hello"
        id value = bindings[cellKeypath];
        NSString *dataKeypath = DXTableParseKeyValue(value);
        if (dataKeypath == nil) {
            // assign `value` directly
            [cell setValue:nilIfNull(value) forKeyPath:cellKeypath];
        } else {
            // `value` is actually a keypath so deal with bindings

            // bind model to views
            if (row.isRepeatable) {
                if (DXTableParseIsDefaultMode(value) || DXTableParseIsToViewMode(value)) {
                    // support for repeatable rows

                    NSString *arrayKeypath = DXTableParseKeyValue(row[DXTableArrayKey]);
                    // stupid way to observe objects in array
                    NSArray *array = [row.dataContext valueForKeyPath:arrayKeypath];
                    // find first index in section of repeatable row
                    NSUInteger firstRowIndex = [row.section.activeRows indexesOfRow:row].firstIndex;
                    NSInteger rowIndex = indexPath.row - firstRowIndex;
                    id item  = array[rowIndex];

                    [modelToViewBindings addObject:
                     [self bindInfoFromDataContext:item
                                       dataKeypath:dataKeypath
                                            toView:cell
                                       viewKeypath:cellKeypath]];
                }
            } else {
                if (DXTableParseIsDefaultMode(value) || DXTableParseIsToViewMode(value)) {
                    DXKVOInfo *modelToView = [self bindInfoFromDataContext:row.dataContext
                                                               dataKeypath:dataKeypath
                                                                    toView:cell
                                                               viewKeypath:cellKeypath];
                    [modelToViewBindings addObject:modelToView];
                }

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
                     if (DXTableParseIsDefaultMode(value) || DXTableParseIsFromViewMode(value)) {
                         if ([object isKindOfClass:[UIControl class]]) {
                             UIControl *control = object;
                             NSDictionary *controlMetaData = [self metaDataForControlClass:[control class]
                                                                              inTableModel:row.section.tableModel];
                             DXValueTarget *target = [self valueTargetForControl:control metaData:controlMetaData];
                             target.valueChanged = ^(id value, UIEvent *event) {
                                 [row.dataContext setValue:nilIfNull(value) forKeyPath:dataKeypath];
                             };
                         } else if ([object isKindOfClass:[UITextView class]]) {
                             DXViewDelegate *delegate = [self viewDelegateForTextView:object];
                             delegate.valueChanged = ^(id value) {
                                 [row.dataContext setValue:nilIfNull(value) forKeyPath:dataKeypath];
                             };
                         }
                     }
                 }];
            }
        }
    }
    FBKVOController *cellKvoController = [self kvoControllerForObject:cell];
    [cellKvoController unobserve:cell];
    for (id info in modelToViewBindings) {
        [self observeWithInfo:info usingKVOController:cellKvoController];
    }
}

@end
