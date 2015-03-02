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
#import "DXFBKVOController.h"
#import <objc/runtime.h>

@interface DXTableObserver ()
{
    struct {
        unsigned delegateRowChange;
        unsigned delegateSectionChange;
    } _observerFlags;
}

@property (nonatomic) DXFBKVOController *kvoController;

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
        self.kvoController = [DXFBKVOController controllerWithObserver:self];
    }
    return self;
}

- (void)setDelegate:(id<DXTableObserverDelegate>)delegate
{
    if (_delegate != delegate) {
        _delegate = delegate;
        SEL rowChangeSelector = @selector(tableObserver:didObserveRowChange:atIndexPaths:forChangeType:newIndexPaths:);
        if ([_delegate respondsToSelector:rowChangeSelector]) {
            _observerFlags.delegateRowChange = true;
        }
        SEL sectionChangeSelector = @selector(tableObserver:didObserveSectionChange:atIndexes:forChangeType:newIndexes:);
        if ([_delegate respondsToSelector:sectionChangeSelector]) {
            _observerFlags.delegateSectionChange = true;
        }
    }
}

- (DXKVOInfo *)infoForRowActiveKeypath:(DXTableRow *)row
                        fromTableModel:(DXTableModel *)tableModel
{
    DXKVOInfo *info = [[DXKVOInfo alloc] init];
    info.object = row;
    info.keypath = @"active";
    info.options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
    __weak id weakSelf = self;
    info.block = ^(DXTableObserver *observer, DXTableRow *row, NSDictionary *change) {
        id strongSelf = weakSelf;
        BOOL isActive = [change[NSKeyValueChangeNewKey] boolValue];
        BOOL wasActive = [change[NSKeyValueChangeOldKey] boolValue];

        if (isActive == wasActive)
            return;

        NSArray *indexPaths = isActive ?
        [tableModel indexPathsOfRow:row] : [tableModel indexPathsOfRowIfWereActive:row];

        DXTableObserverChangeType changeType = isActive ?
        DXTableObserverChangeInsert : DXTableObserverChangeDelete;

        if (_observerFlags.delegateRowChange) {
            [observer.delegate tableObserver:strongSelf
                         didObserveRowChange:row
                                atIndexPaths:indexPaths
                               forChangeType:changeType
                               newIndexPaths:nil];
        }
    };
    return info;
}

- (DXKVOInfo *)infoToTriggerRowActivity:(DXTableRow *)row
{
    id activeValue = row[DXTableActiveKey];
    NSString *keypath = DXTableParseKeyValue(activeValue);
    DXKVOInfo *info;
    if (keypath) {
        info = [[DXKVOInfo alloc] init];
        info.object = row.dataContext;
        info.keypath = DXTableParseKeyValue(activeValue);
        info.options = NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew;
        __weak DXTableRow *weakRow = row;
        info.block = ^(id observer, id dataContext, NSDictionary *change) {
            DXTableRow *strongRow = weakRow;
            id newValue = change[NSKeyValueChangeNewKey];
            if ([newValue isKindOfClass:[NSNumber class]]) {
                // ask NSNumber its boolean value
                strongRow.active = [newValue boolValue];
            } else {
                // check any other object than NSNumber for nil-nes and treat nil/null as false/NO
                strongRow.active = ![newValue isKindOfClass:[NSNull class]];
            }
        };
    }
    return info;
}

- (DXKVOInfo *)infoForSectionActiveKeypath:(DXTableSection *)section
{
    DXKVOInfo *info = [[DXKVOInfo alloc] init];
    info.object = section;
    info.keypath = @"active";
    info.options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
    __weak id weakSelf = self;
    info.block = ^(DXTableObserver *observer, DXTableSection *section, NSDictionary *change) {
        id strongSelf = weakSelf;
        BOOL isActive = [change[NSKeyValueChangeNewKey] boolValue];
        BOOL wasActive = [change[NSKeyValueChangeOldKey] boolValue];

        if (isActive == wasActive)
            return;

        NSUInteger index = isActive ?
        [section.tableModel indexOfSection:section] : [section.tableModel indexOfSectionIfWereActive:section];

        NSIndexSet *indexes = [NSIndexSet indexSetWithIndex:index];

        DXTableObserverChangeType changeType = isActive ?
        DXTableObserverChangeInsert : DXTableObserverChangeDelete;

        if (_observerFlags.delegateSectionChange) {
            [observer.delegate tableObserver:strongSelf
                         didObserveSectionChange:section
                                   atIndexes:indexes
                               forChangeType:changeType
                                  newIndexes:nil];
        }
    };
    return info;
}

- (DXKVOInfo *)intoToTriggerSectionActivity:(DXTableSection *)section
{
    id activeValue = section[DXTableActiveKey];
    NSString *keypath = DXTableParseKeyValue(activeValue);
    DXKVOInfo *info;
    if (keypath) {
        info = [[DXKVOInfo alloc] init];
        info.object = section.dataContext;
        info.keypath = DXTableParseKeyValue(activeValue);
        info.options = NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew;
        __weak DXTableSection *weakSection = section;
        info.block = ^(id observer, id dataContext, NSDictionary *change) {
            DXTableSection *strongSection = weakSection;
            id newValue = change[NSKeyValueChangeNewKey];
            if ([newValue isKindOfClass:[NSNumber class]]) {
                // ask NSNumber its boolean value
                strongSection.active = [newValue boolValue];
            } else {
                // check any other object than NSNumber for nil-nes and treat nil/null as false/NO
                strongSection.active = ![newValue isKindOfClass:[NSNull class]];
            }
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
        __weak DXTableRow *weakRow = row;
        info.block = ^(DXTableObserver *observer, id dataContext, NSDictionary *change) {
            DXTableRow *strongRow = weakRow;
            if (!_observerFlags.delegateRowChange) {
                return;
            }

            NSIndexSet *indexes = change[NSKeyValueChangeIndexesKey];

            NSMutableArray *indexPaths = [NSMutableArray array];
            NSUInteger index = indexes ? indexes.firstIndex : NSNotFound;
            while (index != NSNotFound) {
                NSInteger sectionIndex = [tableModel.activeSections indexOfObject:strongRow.section];
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
                         didObserveRowChange:strongRow
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
                if (row.isRepeatable && DXTableParseIsInnerKeypath(key)) {
                    NSString *arrayKeypath = DXTableParseKeyValue(row[DXTableArrayKey]);
                    NSAssert(arrayKeypath, @"repeatable row must contain %@ keypath", DXTableArrayKey);
                    dataObject = [row.dataContext valueForKeyPath:arrayKeypath][index];
                }
                info.object = dataObject;
                info.keypath = keypath;
                info.options = NSKeyValueObservingOptionNew;
                __weak id weakSelf = self;
                __weak DXTableRow *weakRow = row;
                __weak DXTableModel *weakTableModel = tableModel;
                info.block = ^(id observer, id dataObject, NSDictionary *change) {
                    DXTableObserver *strongSelf = weakSelf;
                    DXTableRow *strongRow = weakRow;
                    DXTableModel *strongTableModel = weakTableModel;
                    
                    if (strongSelf->_observerFlags.delegateRowChange) {
                        NSArray *indexPaths = [strongTableModel indexPathsOfRow:strongRow];
                        [strongSelf.delegate tableObserver:strongSelf
                                 didObserveRowChange:strongRow
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
    
    __weak UIView *weakView = view;
    __weak NSString *weakViewKeypath = viewKeypath;
    info.block = ^(id observer, id object, NSDictionary *change) {
        UIView *strongView = weakView;
        NSString *strongViewKeypath = weakViewKeypath;
        id newValue = change[NSKeyValueChangeNewKey];
        id oldValue = [strongView valueForKeyPath:strongViewKeypath];
        if (NO == [newValue isEqual:oldValue]) {
            [strongView setValue:nilIfNull(newValue) forKeyPath:strongViewKeypath];
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

- (DXFBKVOController *)kvoControllerForObject:(id)object
{
    static void *ObjectKvoControllerKey = &ObjectKvoControllerKey;
    // while `object` exists `kvoController` exists as well
    DXFBKVOController *kvoController = objc_getAssociatedObject(object, ObjectKvoControllerKey);
    if (kvoController == nil) {
        kvoController = [DXFBKVOController controllerWithObserver:object];
        objc_setAssociatedObject(object, ObjectKvoControllerKey, kvoController, OBJC_ASSOCIATION_RETAIN);
    }
    return kvoController;
}

- (DXValueTarget *)valueTargetForControl:(UIControl *)control metaData:(NSDictionary *)metaData
{
    static void *ControlValueTargetKey = &ControlValueTargetKey;
    // while `control` exists `target` exists as well
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
    // make it possibl to provide delegate from client's code checking whenever textView have delegate already set
    if (delegate == nil && textView.delegate == nil) {
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

- (void)observeWithInfo:(DXKVOInfo *)info usingKVOController:(DXFBKVOController *)kvoController
{
    [kvoController observe:info.object keyPath:info.keypath options:info.options block:info.block];
}

- (void)startObservingTableModel:(DXTableModel *)tableModel
{
    NSMutableArray *infos = [NSMutableArray array];
    for (DXTableSection *section in tableModel.allSections) {
        // subscribe to each section "active" keypath
        addObjectIfNotNil(infos, [self infoForSectionActiveKeypath:section]);
        addObjectIfNotNil(infos, [self intoToTriggerSectionActivity:section]);
        for (DXTableRow *row in section.allRows) {
            addObjectIfNotNil(infos, [self infoForRowActiveKeypath:row
                                                    fromTableModel:tableModel]);
            addObjectIfNotNil(infos, [self infoToTriggerRowActivity:row]);
            addObjectIfNotNil(infos, [self infoForRepeatableRow:row
                                                 fromTableModel:tableModel]);

            [infos addObjectsFromArray:[self infosToTriggerUpdateCellForRow:row
                                                             fromTableModel:tableModel]];
        }
    }

    for (DXKVOInfo *info in infos) {
        [self observeWithInfo:info];
    }
}

- (void)stopObserving
{
    [self.kvoController unobserveAll];
}

// FIXME: unify this method with setupBindingsForCell:… now it's copy-paste and decouple logic
- (void)setupBindingsForView:(UIView *)view item:(DXTableItem *)item inDataContext:(id)dataContext
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
                DXKVOInfo *info = [self bindInfoFromDataContext:dataContext
                                                    dataKeypath:dataKeypath
                                                         toView:view
                                                    viewKeypath:viewKeypath];
                [modelToViewBindings addObject:info];
            }
        }
    }

    DXFBKVOController *viewKvoController = [self kvoControllerForObject:view];
    [viewKvoController unobserve:dataContext];
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
            if (DXTableParseIsDefaultMode(value) || DXTableParseIsToViewMode(value)) {
                    id dataObject = row.dataContext;
                    if (row.isRepeatable) {
                        NSString *arrayKeypath = DXTableParseKeyValue(row[DXTableArrayKey]);
                        NSAssert(arrayKeypath, @"repeatable row must contain %@ keypath", DXTableArrayKey);
                        // stupid way to observe objects in array
                        NSArray *array = [row.dataContext valueForKeyPath:arrayKeypath];
                        // find first index in section of repeatable row
                        NSUInteger firstRowIndex = [row.section.activeRows indexesOfRow:row].firstIndex;
                        NSInteger rowIndex = indexPath.row - firstRowIndex;
                        dataObject  = array[rowIndex];
                    }

                    DXKVOInfo *modelToView = [self bindInfoFromDataContext:dataObject
                                                               dataKeypath:dataKeypath
                                                                    toView:cell
                                                               viewKeypath:cellKeypath];
                    [modelToViewBindings addObject:modelToView];
            }

            // bind views (controls) to model
            // lookup UIControl objects traversing through cellKeypath components
            // "textField.text"
            if (DXTableParseIsDefaultMode(value) || DXTableParseIsFromViewMode(value)) {
                id dataObject = row.dataContext;
                if (row.isRepeatable) {
                    NSString *arrayKeypath = DXTableParseKeyValue(row[DXTableArrayKey]);
                    NSAssert(arrayKeypath, @"repeatable row must contain %@ keypath", DXTableArrayKey);
                    NSArray *array = [row.dataContext valueForKeyPath:arrayKeypath];
                    // find first index in section of repeatable row
                    NSUInteger firstRowIndex = [row.section.activeRows indexesOfRow:row].firstIndex;
                    NSInteger rowIndex = indexPath.row - firstRowIndex;
                    dataObject  = array[rowIndex];
                }

                NSArray *cellKeypathComponents = [cellKeypath componentsSeparatedByString:@"."];
                [cellKeypathComponents enumerateObjectsUsingBlock:
                 ^(NSString *component, NSUInteger idx, BOOL *stop) {
                     NSString *leftSideKeypath =
                     [[cellKeypathComponents subarrayWithRange:NSMakeRange(0, idx + 1)]
                      componentsJoinedByString:@"."];
                     id object = [cell valueForKeyPath:leftSideKeypath];
                     if ([object isKindOfClass:[UIControl class]]) {
                         UIControl *control = object;
                         NSDictionary *controlMetaData = [self metaDataForControlClass:[control class]
                                                                          inTableModel:row.section.tableModel];
                         DXValueTarget *target = [self valueTargetForControl:control metaData:controlMetaData];
                         
                         __weak id weakDataObject = dataObject;
                         target.valueChanged = ^(id value, UIEvent *event) {
                             id strongDataObject = weakDataObject;
                             id oldValue = [strongDataObject valueForKeyPath:dataKeypath];
                             if (NO == [value isEqual:oldValue]) {
                                 [strongDataObject setValue:nilIfNull(value) forKeyPath:dataKeypath];
                             }
                         };
                     } else if ([object isKindOfClass:[UITextView class]]) {
                         DXViewDelegate *delegate = [self viewDelegateForTextView:object];
                         __weak id weakDataObject = dataObject;
                         delegate.valueChanged = ^(id value) {
                             id strongDataObject = weakDataObject;
                             id oldValue = [strongDataObject valueForKeyPath:dataKeypath];
                             if (NO == [value isEqual:oldValue]) {
                                 [strongDataObject setValue:nilIfNull(value) forKeyPath:dataKeypath];
                             }
                         };
                     }
                 }];
            }
        }
    }
    DXFBKVOController *cellKvoController = [self kvoControllerForObject:cell];
    // unobserve
    for (DXKVOInfo *info in modelToViewBindings) {
        [cellKvoController unobserve:info.object];
    }
    // observe
    for (DXKVOInfo *info in modelToViewBindings) {
        [self observeWithInfo:info usingKVOController:cellKvoController];
    }
}

@end
