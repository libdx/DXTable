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
      DXTableHeaderKey: @"Event",
      DXTableRowsKey:
          @[@{DXTableNameKey: @"title",
              DXTableNibKey: @"FieldCell",
              DXTableBindingsKey:
                  @{@"titleLabel.text": @"Title",
                    @"textField.text": @"@title",
                    @"textField.placeholder": @"Title your event",
                    @"textField.inputAccessoryView": [self inputAccessoryView]}
              },
            @{DXTableNameKey: @"location",
              DXTableBindingsKey:
                  @{@"textLabel.text": @"Location"}
              }
            ]
      };

    NSDictionary *datesSection =
    @{DXTableNameKey: @"dates",
      DXTableHeaderKey: @"Setup Dates",
      DXTableRowsKey:
          @[@{DXTableNameKey: @"dueDate",
              DXTableNibKey: @"SwitchCell",
              DXTableTargetKey: self.viewModel,
              DXTableActionsKey:
                  @{DXTableRowDidSelectActionKey: @"toggleShowDueDatePicker"},
              DXTableBindingsKey:
                  @{@"titleLabel.text": @"Due date (Tap me)",
                    @"switchControl.on": @"@showsDueDatePicker"}
              },
            @{DXTableNameKey: @"dueDatePicker",
              DXTableNibKey: @"DatePickerCell",
              DXTableActiveKey: @"@showsDueDatePicker",
              DXTableHeightKey: @216,
              DXTableBindingsKey:
                  @{@"datePicker.date": @"@dueDate"}
              },
            @{DXTableNameKey: @"alert",
              DXTableBindingsKey:
                  @{@"textLabel.text": @"Alert",
                    @"accessoryType": @(UITableViewCellAccessoryDisclosureIndicator)}
              },
            @{DXTableNameKey: @"toggleNext",
              DXTableBindingsKey:
                  @{@"textLabel.text": @"Toggle next section"},
              DXTableTargetKey: self.viewModel,
              DXTableActionsKey:
                  @{DXTableRowDidSelectActionKey: @"toggleTogglableSection"}
              }
            ]
      };

    NSDictionary *togglableSection =
    @{DXTableNameKey: @"togglable",
      DXTableActiveKey: @"@togglableSectionShown",
      DXTableHeaderKey: @"Togglable Section",
      DXTableRowsKey:
          @[@{DXTableNameKey: @"togglableSectionCell",
              DXTableBindingsKey:
                  @{@"textLabel.text": @"Cell in togglable section"}
              },
            ]
      };

    NSDictionary *stuffSection =
    @{DXTableNameKey: @"stuff",
      DXTableHeaderKey: @"Stuff to get",
      DXTableRowsKey:
          @[@{DXTableNameKey: @"thing",
              DXTableRepeatableKey: @YES,
              DXTableArrayKey: @"@things",
              DXTableBindingsKey:
                  @{@"textLabel.text": @"@.name"}},
            
            @{DXTableNameKey: @"newThing",
              DXTableTargetKey: self.viewModel,
              DXTableActionsKey:
                  @{DXTableRowDidSelectActionKey: @"addThing"},
              DXTableBindingsKey:
                  @{@"textLabel.text": @"Add new thing"}
              },
            ]
      };

    NSDictionary *notesSection =
    @{DXTableNameKey: @"notes",
      DXTableHeaderKey: @"Misc.",
      DXTableRowsKey:
          @[@{DXTableNameKey: @"url",
              DXTableBindingsKey:
                  @{@"textLabel.text": @"URL"}
              },
            @{DXTableNameKey: @"notes",
              DXTableHeightKey: @80,
              DXTableBindingsKey:
                  @{@"textLabel.text": @"Notes"}
              }
            ]
      };

    NSDictionary *eventModel =
    @{DXTableNameKey: @"Event",
      DXTableSectionsKey:
          @[headSection, datesSection, togglableSection, stuffSection, notesSection]
      };

    self.tableModel = [[DXTableModel alloc] initWithDataContext:self.viewModel options:eventModel];
    self.tableViewSource = [[DXTableViewSource alloc]
                            initWithTableView:self.tableView
                            tableModel:self.tableModel
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
