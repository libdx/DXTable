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
#import "DXTableRowArray.h"
#import "DXTableObserver.h"
#import "FBKVOController.h"
#import "DXBindings.h"

#import <objc/runtime.h>

@interface DXTableViewSource () <DXTableObserverDelegate>

@property (nonatomic) DXTableModel *tableModel;
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic) DXTableObserver *tableObserver;
@property (nonatomic) FBKVOController *kvoController;

@end

static UIResponder *lookupRespondent(UIResponder *topResponder, SEL action)
{
    UIResponder *responder = topResponder;
    while (responder) {
        if ([responder respondsToSelector:action]) {
            break;
        }
        responder = [responder nextResponder];
    }
    return responder;
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
                          options:(NSDictionary *)options;
{
    self = [super init];
    if (self) {
        self.tableModel = tableModel;
        self.tableView = tableView;
        tableView.delegate = self;
        tableView.dataSource = self;
        self.kvoController = [FBKVOController controllerWithObserver:self];
        self.tableObserver = [[DXTableObserver alloc] init];
        self.tableObserver.delegate = self;

        [self.tableObserver startObservingTableModel:tableModel inDataContext:tableModel.dataContext];

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
    }
    return self;
}

#pragma mark - DXTableObserverDelegate

- (void)tableObserver:(DXTableObserver *)observer
  didObserveRowChange:(DXTableRow *)row
         atIndexPaths:(NSArray *)indexPaths
        forChangeType:(DXTableObserverChangeType)changeType
        newIndexPaths:(NSArray *)newIndexPaths;
{
    if (changeType == DXTableObserverChangeInsert) {
        [self.tableView insertRowsAtIndexPaths:indexPaths
                              withRowAnimation:UITableViewRowAnimationFade];
    } else if (changeType == DXTableObserverChangeDelete) {
        [self.tableView deleteRowsAtIndexPaths:indexPaths
                              withRowAnimation:UITableViewRowAnimationFade];
    } else if (changeType == DXTableObserverChangeSetting) {
            [self.tableView reloadData];
    } else if (changeType == DXTableObserverChangeUpdate) {
        [self.tableView reloadRowsAtIndexPaths:indexPaths
                              withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.tableModel.activeSections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tableModel.activeSections[section] activeRows].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DXTableRow *row = [self.tableModel.activeSections[indexPath.section] activeRows][indexPath.row];
    id cell = [tableView dequeueReusableCellWithIdentifier:row[DXTableNameKey]
                                              forIndexPath:indexPath];
    [self.tableObserver setupBindingsForCell:cell row:row atIndexPath:indexPath inDataContext:self.tableModel.dataContext];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.tableModel.activeSections[section][DXTableHeaderKey];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return self.tableModel.activeSections[section][DXTableFooterKey];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DXTableSection * section = self.tableModel.activeSections[indexPath.section];
    return section.activeRows[indexPath.row].height;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    DXTableRow *row = [self.tableModel.activeSections[indexPath.section] activeRows][indexPath.row];
    return row.isEditable;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    DXTableRow *row = [self.tableModel.activeSections[indexPath.section] activeRows][indexPath.row];
    SEL action;
    if (row.editingStyle == UITableViewCellEditingStyleInsert) {
        action = NSSelectorFromString(row[DXTableActionsKey][DXTableRowCommitInsertActionKey]);
    } else if (row.editingStyle == UITableViewCellEditingStyleDelete) {
        action = NSSelectorFromString(row[DXTableActionsKey][DXTableRowCommitDeleteActionKey]);
    }
    if (action) {
        id target = row.target;
        if (target == nil) {
            target = lookupRespondent(tableView, action);
        }
        [[UIApplication sharedApplication] sendAction:action
                                                   to:target
                                                 from:indexPath
                                             forEvent:nil];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    DXTableSection *section = self.tableModel.activeSections[indexPath.section];
    DXTableRow *row = section.activeRows[indexPath.row];
    SEL action = NSSelectorFromString(row[DXTableActionsKey][DXTableRowDidSelectActionKey]);
    if (action) {
        id target = row.target;
        if (target == nil) {
            target = lookupRespondent(tableView, action);
        }
        [[UIApplication sharedApplication] sendAction:action
                                                   to:target
                                                 from:indexPath
                                             forEvent:nil];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DXTableRow *row = [self.tableModel.activeSections[indexPath.section] activeRows][indexPath.row];
    return row.editingStyle;
}

@end

NSString *DXTableViewSourceCellClassKey = @"CellClass";
NSString *DXTableViewSourceInsertAnimationKey = @"InsertAnimation";
NSString *DXTableViewSourceUseLocalizedStringKey = @"UseLocalizedString";
NSString *DXTableViewSourceCanEditRowsKey = @"CanEditRows";
