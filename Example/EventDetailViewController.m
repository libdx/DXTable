//
//  EventDetailViewController.m
//  Pieces
//
//  Created by Alexander Ignatenko on 23/05/14.
//  Copyright (c) 2014 Alexander Ignatenko. All rights reserved.
//

#import <DXTable.h>
#import "EventDetailViewController.h"
#import "EventViewModel.h"

@interface EventDetailViewController ()

@property (nonatomic) DXTableModel *tableModel;
@property (nonatomic) DXTableViewSource *tableViewSource;
@property (nonatomic) EventViewModel *viewModel;

@end

static void traversalViews(UIView *view, void (^callback)(UIView *view))
{
    callback(view);
    for (UIView *subview in view.subviews) {
        traversalViews(subview, callback);
    }
}

static UIView *lookupFirstResponder(UIView *view)
{
    __block UIView *firstResponder;
    traversalViews(view, ^(UIView *view) {
        if ([view isFirstResponder]) {
            firstResponder = view;
        }
    });
    return firstResponder;
}

@implementation EventDetailViewController

#pragma mark - Lifecycle

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    return [super initWithStyle:UITableViewStyleGrouped];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSDictionary *headSection =
    @{DXTableNameKey: @"head",
      DXTableTitleKey: @"Event",
      DXTableRowsKey:
          @[@{DXTableNameKey: @"title",
              DXTableRowNibKey: @"FieldCell",
              DXTablePropertiesKey:
                  @{@"titleLabel.text": @"Title",
                    @"textField.text": @"@title",
                    @"textField.placeholder": @"Title your event",
                    @"textField.inputAccessoryView": [self inputAccessoryView]}
              },
            @{DXTableNameKey: @"location",
              DXTablePropertiesKey:
                  @{@"textLabel.text": @"Location"}
              }
            ]
      };

    NSDictionary *datesSection =
    @{DXTableNameKey: @"dates",
      DXTableTitleKey: @"Setup Dates",
      DXTableRowsKey:
          @[@{DXTableNameKey: @"dueDate",
              DXTableRowNibKey: @"SwitchCell",
              DXTableTargetKey: self.viewModel,
              DXTableActionsKey:
                  @{DXTableRowDidSelectActionKey: @"toggleShowDueDatePicker"},
              DXTablePropertiesKey:
                  @{@"titleLabel.text": @"Due date (Tap me)",
                    @"switchControl.on": @"@showsDueDatePicker"}
              },
            @{DXTableNameKey: @"dueDatePicker",
              DXTableRowNibKey: @"DatePickerCell",
              DXTableActiveKey: @"@showsDueDatePicker",
              DXTableHeightKey: @216,
              DXTablePropertiesKey:
                  @{@"datePicker.date": @"@dueDate"}
              },
            @{DXTableNameKey: @"alert",
              DXTablePropertiesKey:
                  @{@"textLabel.text": @"Alert",
                    @"accessoryType": @(UITableViewCellAccessoryDisclosureIndicator)}
              }
            ]
      };

    NSDictionary *stuffSection =
    @{DXTableNameKey: @"stuff",
      DXTableTitleKey: @"Stuff to get",
      DXTableRowsKey:
          @[@{DXTableNameKey: @"thing",
              DXTableRepeatableKey: @YES,
              DXTableListKey: @"@things",
              DXTablePropertiesKey:
                  @{@"textLabel.text": @"@.name"}},
            
            @{DXTableNameKey: @"newThing",
              DXTableTargetKey: self.viewModel,
              DXTableActionsKey:
                  @{DXTableRowDidSelectActionKey: @"addThing"},
              DXTablePropertiesKey:
                  @{@"textLabel.text": @"Add new thing"}
              },
            ]
      };

    NSDictionary *notesSection =
    @{DXTableNameKey: @"notes",
      DXTableTitleKey: @"Misc.",
      DXTableRowsKey:
          @[@{DXTableNameKey: @"url",
              DXTablePropertiesKey:
                  @{@"textLabel.text": @"URL"}
              },
            @{DXTableNameKey: @"notes",
              DXTableHeightKey: @80,
              DXTablePropertiesKey:
                  @{@"textLabel.text": @"Notes"}
              }
            ]
      };

    NSDictionary *eventModel =
    @{DXTableNameKey: @"Event",
      DXTableSectionsKey:
          @[headSection, datesSection, stuffSection, notesSection]
      };

    self.tableModel = [[DXTableModel alloc] initWithOptions:eventModel];
    self.tableViewSource = [[DXTableViewSource alloc]
                            initWithTableView:self.tableView
                            tableModel:self.tableModel
                            dataContext:self.viewModel
                            options:@{DXTableViewSourceCellClassKey:
                                          [UITableViewCell class]}];
}

- (EventViewModel *)viewModel
{
    if (_viewModel == nil) {
        _viewModel = [[EventViewModel alloc] init];
//        _viewModel.title = @"Rock-n-roll party";
    }
    return _viewModel;
}

- (UIToolbar *)inputAccessoryView
{
    UIBarButtonItem *done = [[UIBarButtonItem alloc]
                             initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                             target:self
                             action:@selector(dismissKeyboard)];
    UIBarButtonItem *space = [[UIBarButtonItem alloc]
                              initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                              target:nil
                              action:NULL];
    UIBarButtonItem *next = [[UIBarButtonItem alloc]
                             initWithTitle:@"Next"
                             style:UIBarButtonItemStyleBordered
                             target:self
                             action:@selector(makeNextFirstResponder)];
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    toolbar.items = @[done, space, next];
    [toolbar sizeToFit];
    return toolbar;
}

- (void)dismissKeyboard
{
    [self.view endEditing:NO];
}

- (void)makeNextFirstResponder
{
//    UIView *firstResponder = lookupFirstResponder(self.view);
}

#pragma mark - Visual Tests

- (void)visualOneWayBindingsTest
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.viewModel.title = @"Halloween";
    });
}

- (void)visualInsertDeleteRowsTest
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[self.tableModel.activeSections[1] allRows][1] setActive:YES];
        [[self.tableModel.activeSections[1] allRows][2] setActive:NO];
        [[self.tableModel.activeSections[0] allRows][0] setActive:NO];
        [[self.tableModel.activeSections[2] allRows][1] setActive:NO];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[self.tableModel.activeSections[1] allRows][1] setActive:NO];
            [[self.tableModel.activeSections[1] allRows][2] setActive:YES];
            [[self.tableModel.activeSections[0] allRows][0] setActive:YES];
            [[self.tableModel.activeSections[2] allRows][1] setActive:YES];
        });
    });
}

@end
