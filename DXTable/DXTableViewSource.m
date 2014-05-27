//
//  DXTableViewSource.m
//  Pieces
//
//  Created by Alexander Ignatenko on 22/05/14.
//  Copyright (c) 2014 Alexander Ignatenko. All rights reserved.
//

#import "DXTableViewSource.h"
#import "DXTableModel.h"
#import "DXTableSection.h"
#import "DXTableRow.h"
#import "FBKVOController.h"
#import "DXBindings.h"

#import <objc/runtime.h>

@interface DXTableViewSource ()

@property (nonatomic) DXTableModel *tableModel;
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) id dataContext;

@property (nonatomic) FBKVOController *kvoController;

@end

static id nilIfNull(id object)
{
    return [object isKindOfClass:[NSNull class]] ? nil : object;
}

static Class classFromClassOrName(id classOrString)
{
    return [classOrString isKindOfClass:[NSString class]] ?
    NSClassFromString(classOrString) : classOrString;
}

static UINib *nibFromNibOrName(id nibOrString)
{
    return [nibOrString isKindOfClass:[NSString class]] ?
    [UINib nibWithNibName:nibOrString bundle:nil] : nibOrString;
}

@implementation DXTableViewSource

- (instancetype)initWithTableView:(UITableView *)tableView
                       tableModel:(DXTableModel *)tableModel
                      dataContext:(id)dataContext
                          options:(NSDictionary *)options;
{
    self = [super init];
    if (self) {
        self.tableModel = tableModel;
        self.dataContext = dataContext;
        self.tableView = tableView;
        self.kvoController = [FBKVOController controllerWithObserver:self];
        tableView.delegate = self;
        tableView.dataSource = self;

        // TODO: add on table model method that returns dictionary of cell classes and nibs
        // register cell classes and nibs
        for (DXTableSection *section in
             self.tableModel[DXTableSectionsKey])
        {
            for (DXTableRow *row in section[DXTableRowsKey]) {
                Class cls = classFromClassOrName(row[DXTableRowClassKey]);
                UINib *nib = nibFromNibOrName(row[DXTableRowNibKey]);
                NSString *identifier = row[DXTableNameKey];
                cls = cls || nib ? cls : options[DXTableViewSourceCellClassKey];
                if (cls) {
                    [tableView registerClass:cls forCellReuseIdentifier:identifier];
                } else {
                    [tableView registerNib:nib forCellReuseIdentifier:identifier];
                }
            }
        }

        // subscribe to each row "enabled" keypath
        for (DXTableSection *section in self.tableModel.allSections) {
            for (DXTableRow *row in section.allRows) {
                [self.kvoController observe:row keyPath:@"enabled" options:NSKeyValueObservingOptionNew block:
                 ^(DXTableViewSource *observer, DXTableRow *row, NSDictionary *change) {
                     BOOL isEnabled = [change[NSKeyValueChangeNewKey] boolValue];
                     NSArray *indexPathsToInsert;
                     NSArray *indexPathsToDelete;
                     if (isEnabled) {
                         indexPathsToInsert = @[[self.tableModel indexPathOfRow:row]];
                     } else {
                         indexPathsToDelete = @[[self.tableModel indexPathOfRowIfWereEnabled:row]];
                     }

                     [observer.tableView beginUpdates];
                     [observer.tableView insertRowsAtIndexPaths:indexPathsToInsert
                                               withRowAnimation:UITableViewRowAnimationFade];
                     [observer.tableView deleteRowsAtIndexPaths:indexPathsToDelete
                                               withRowAnimation:UITableViewRowAnimationFade];
                     [observer.tableView endUpdates];
                 }];
            }
        }

        // subscribe to each section "enabled" keypath
        // TODO

        // subscribe to some of rows' keypaths (wat?)
        for (DXTableSection *section in self.tableModel.allSections) {
            for (DXTableRow *row in section.allRows) {
                id enabledValue = row[DXTableEnabledKey];
                NSString *keypath = DXTableKeypathFromObject(enabledValue);
                if (keypath) {
                    NSKeyValueObservingOptions options =
                    NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew;
                    [self.kvoController observe:self.dataContext keyPath:keypath options:options block:
                    ^(id observer, id object, NSDictionary *change) {
                        row.enabled = [change[NSKeyValueChangeNewKey] boolValue];
                    }];
                }
            }
        }
    }
    return self;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.tableModel.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tableModel.sections[section] rows].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DXTableRow *row = [self.tableModel.sections[indexPath.section] rows][indexPath.row];
    id cell = [tableView dequeueReusableCellWithIdentifier:row[DXTableNameKey]
                                              forIndexPath:indexPath];

    NSDictionary *bindings = row[DXTablePropertiesKey];
    for (NSString *cellKeypath in bindings) { // "textLabel.text": "Hello"
        id value = bindings[cellKeypath];
        NSString *dataKeypath = DXTableKeypathFromObject(value);
        if (dataKeypath == nil) {
            // assign `value` directly
            [cell setValue:nilIfNull(value) forKeyPath:cellKeypath];
        } else {
            // `value` is actually a keypath then dealing with bindings

            // bind model to views
            FBKVOController *cellKvoController = [FBKVOController controllerWithObserver:cell];
            static void *cellKvoControllerKey = &cellKvoControllerKey;
            objc_setAssociatedObject(cell, cellKvoControllerKey, cellKvoController, OBJC_ASSOCIATION_RETAIN);
            NSKeyValueObservingOptions options =
            NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew;
            [cellKvoController observe:self.dataContext keyPath:dataKeypath options:options block:
            ^(id observer, id object, NSDictionary *change) {
                id newValue = change[NSKeyValueChangeNewKey];
                [cell setValue:nilIfNull(newValue) forKeyPath:cellKeypath];
            }];

            // bind views (controls) to model
            // lookup UIControl objects among traversing through cellKeypath components
            // "textField.text"
            // FIXME: use runtime to retrieve this information,
            // because objects at specified keypaths might be nil during this code execution
            NSArray *cellKeypathComponents = [cellKeypath componentsSeparatedByString:@"."];
            [cellKeypathComponents enumerateObjectsUsingBlock:
            ^(NSString *component, NSUInteger idx, BOOL *stop) {
                NSString *leftSideKeypath =
                [[cellKeypathComponents subarrayWithRange:NSMakeRange(0, idx + 1)]
                 componentsJoinedByString:@"."];
                id object = [cell valueForKeyPath:leftSideKeypath];
                if ([object isKindOfClass:[UIControl class]]) {
                    UIControl *control = object;
                    DXValueTarget *target = [[DXValueTarget alloc] init];
                    [target becomeTargetOfControl:control];
                    [target setValueChanged:^(id value, UIEvent *event) {
                        [self.dataContext setValue:nilIfNull(value) forKeyPath:dataKeypath];
                    }];
                    static void *ControlValueTargetKey = &ControlValueTargetKey;
                    objc_setAssociatedObject(control, ControlValueTargetKey, target, OBJC_ASSOCIATION_RETAIN);
                }
            }];
        }
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.tableModel.sections[section][DXTableTitleKey];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DXTableSection *section = self.tableModel.sections[indexPath.section];
    NSNumber *height = section.rows[indexPath.row][DXTableHeightKey];
    return height ? height.floatValue : UITableViewAutomaticDimension;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DXTableSection *section = self.tableModel.sections[indexPath.section];
    DXTableRow *row = section.rows[indexPath.row];
    SEL action = NSSelectorFromString(row[DXTableActionsKey][DXTableRowDidSelectActionKey]);
    if (action) {
        [[UIApplication sharedApplication] sendAction:action
                                                   to:self.dataContext
                                                 from:nil
                                             forEvent:nil];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end

NSString *DXTableViewSourceCellClassKey = @"CellClass";
NSString *DXTableViewSourceInsertAnimationKey = @"InsertAnimation";
