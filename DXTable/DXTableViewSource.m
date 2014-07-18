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
#import "DXBindings.h"

#import <objc/runtime.h>

@interface DXTableViewSource () <DXTableObserverDelegate>

@property (nonatomic, strong) DXTableModel *tableModel;
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) DXTableObserver *tableObserver;
@property (nonatomic, copy) NSDictionary *options;

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
        self.tableObserver = [[DXTableObserver alloc] init];
        self.tableObserver.delegate = self;
        self.options = options;

        [self.tableObserver startObservingTableModel:tableModel];
        [self registerResourcesForTableView:tableView];
    }
    return self;
}

- (void)registerResourcesForTableView:(UITableView *)tableView
{
    if (tableView == nil) {
        return;
    }
    if ([tableView respondsToSelector:@selector(setSectionIndexBackgroundColor:)]) {
        tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    }
    // TODO: add on table model method that returns dictionary of cell classes and nibs
    // register cell classes and nibs
    for (DXTableSection *section in self.tableModel.allSections)
    {
        // register classes and nibs for header and footer views
        [self registerViewResourcesOfRow:section.header forTableView:tableView];
        [self registerViewResourcesOfRow:section.footer forTableView:tableView];

        // register classes and nibs for cells
        for (DXTableRow *row in section[DXTableRowsKey]) {
            [self registerCellResourcesOfRow:row forTableView:tableView];
        }
    }
}

- (void)registerViewResourcesOfRow:(DXTableItem *)item forTableView:(UITableView *)tableView
{
    if (item == nil) {
        return;
    }

    Class cls = classFromClassOrName(item[DXTableClassKey]);
    UINib *nib = nibFromNibOrName(item[DXTableNibKey]);
    NSString *identifier = item[DXTableNameKey];
    cls = cls || nib ? cls : self.options[DXTableViewSourceCellClassKey];
    if (cls) {
        [tableView registerClass:cls forHeaderFooterViewReuseIdentifier:identifier];
    } else {
        [tableView registerNib:nib forHeaderFooterViewReuseIdentifier:identifier];
    }
}

- (void)registerCellResourcesOfRow:(DXTableRow *)row forTableView:(UITableView *)tableView
{
    if (row == nil) {
        return;
    }

    Class cls = classFromClassOrName(row[DXTableClassKey]);
    UINib *nib = nibFromNibOrName(row[DXTableNibKey]);
    NSString *identifier = row[DXTableNameKey];
    cls = cls || nib ? cls : self.options[DXTableViewSourceCellClassKey];
    if (cls) {
        [tableView registerClass:cls forCellReuseIdentifier:identifier];
    } else {
        [tableView registerNib:nib forCellReuseIdentifier:identifier];
    }
}

#pragma mark - DXTableObserverDelegate

- (void)tableObserver:(DXTableObserver *)observer
  didObserveRowChange:(DXTableRow *)row
         atIndexPaths:(NSArray *)indexPaths
        forChangeType:(DXTableObserverChangeType)changeType
        newIndexPaths:(NSArray *)newIndexPaths
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

- (void)tableObserver:(DXTableObserver *)observer
didObserveSectionChange:(DXTableSection *)section
            atIndexes:(NSIndexSet *)indexes
        forChangeType:(DXTableObserverChangeType)changeType
           newIndexes:(NSIndexSet *)newIndexes
{
    if (changeType == DXTableObserverChangeInsert) {
        [self.tableView insertSections:indexes
                              withRowAnimation:UITableViewRowAnimationFade];
    } else if (changeType == DXTableObserverChangeDelete) {
        [self.tableView deleteSections:indexes
                              withRowAnimation:UITableViewRowAnimationFade];
    } else if (changeType == DXTableObserverChangeSetting) {
        [self.tableView reloadData];
    } else if (changeType == DXTableObserverChangeUpdate) {
        [self.tableView reloadSections:indexes
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
    [self.tableObserver setupBindingsForCell:cell row:row atIndexPath:indexPath];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.tableModel.activeSections[section] headerTitle];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return [self.tableModel.activeSections[section] footerTitle];
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

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DXTableSection *section = self.tableModel.activeSections[indexPath.section];
    DXTableRow *row = section.activeRows[indexPath.row];
    return row.isSelectionEnabled ? indexPath : nil;
}

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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    DXTableSection *sectionItem = self.tableModel.activeSections[section];
    if (sectionItem.header == nil) {
        return nil;
    }
    UIView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:sectionItem.header[DXTableNameKey]];
    [self.tableObserver setupBindingsForView:view item:sectionItem.header inDataContext:sectionItem.dataContext];
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    DXTableSection *sectionItem = self.tableModel.activeSections[section];
    if (sectionItem.footer == nil) {
        return nil;
    }
    UIView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:sectionItem.footer[DXTableNameKey]];
    [self.tableObserver setupBindingsForView:view item:sectionItem.footer inDataContext:sectionItem.dataContext];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    DXTableSection *sectionItem = self.tableModel.activeSections[section];
    return sectionItem.headerHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    DXTableSection *sectionItem = self.tableModel.activeSections[section];
    return sectionItem.footerHeight;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    DXTableSection *section = self.tableModel.activeSections[indexPath.section];
    DXTableRow *row = section.activeRows[indexPath.row];
    return row.shouldIndentWhileEditing;
}

@end

NSString *DXTableViewSourceCellClassKey = @"CellClass";
NSString *DXTableViewSourceInsertAnimationKey = @"InsertAnimation";
NSString *DXTableViewSourceUseLocalizedStringKey = @"UseLocalizedString";
NSString *DXTableViewSourceCanEditRowsKey = @"CanEditRows";
