//
//  DXTableItemTests.m
//  DXTable
//
//  Created by Alexander Ignatenko on 10/07/14.
//  Copyright (c) 2014 Alexander Ignatenko. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DXTableItem.h"

@interface DXTableItemTests : XCTestCase

@end

@implementation DXTableItemTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testActions
{
    NSString *const ItemDidSelectAction = @"didSelect";
    NSString *const ItemWillSelectAction = @"willSelect";
    NSString *const ItemInsertAction = @"insert";
    NSString *const ItemDeleteAction = @"delete";
    NSString *const ItemUpdateAction = @"update";

    NSString *fooSelector = @"foo";
    NSString *barSelector = @"bar";
    NSString *coolSelector = @"cool";
    NSString *otherSelector = @"other";
    BOOL isCoolEnabled = YES;
    BOOL isOtherEnabled = NO;
    NSDictionary *options = @{DXTableActionsKey:
                                  @{ItemDidSelectAction: fooSelector,
                                    ItemWillSelectAction: barSelector,
                                    ItemInsertAction: @{DXTableSelectorKey: coolSelector, DXTableEnabledKey: @(isCoolEnabled)},
                                    ItemDeleteAction: @{DXTableSelectorKey: otherSelector, DXTableEnabledKey: @(isOtherEnabled)},
                                    ItemUpdateAction: @NO}
                              };
    DXTableItem *item = [[DXTableItem alloc] initWithOptions:options];

    XCTAssertNotNil(item.actions[ItemDidSelectAction], @"Expects ItemDidSelectAction value to be not `nil`");
    XCTAssertNotNil(item.actions[ItemWillSelectAction], @"Expects ItemWillSelectAction value to be not `nil`");
    XCTAssertNotNil(item.actions[ItemInsertAction], @"Expects ItemInsertAction value to be not `nil`");
    XCTAssertNil(item.actions[ItemDeleteAction], @"Expects ItemDeleteAction value to be `nil`");
    XCTAssertNil(item.actions[ItemUpdateAction], @"Expects ItemUpdateAction value to be `nil`");

    XCTAssertEqualObjects(item.actions[ItemDidSelectAction], fooSelector, @"Expects ItemDidSelectAction value to be equal to %@", fooSelector);
    XCTAssertEqualObjects(item.actions[ItemWillSelectAction], barSelector, @"Expects ItemWillSelectAction value to be equal to %@", barSelector);
    XCTAssertEqualObjects(item.actions[ItemInsertAction], coolSelector, @"Expects ItemInsertAction value to be equal to %@", coolSelector);
}

@end
