//
//  DXTableTestsParse.m
//  DXTableTests
//
//  Created by Alexander Ignatenko on 17/06/14.
//  Copyright (c) 2014 Alexander Ignatenko. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "DXTableParse.h"
#import "DXTableItem.h"

@interface DXTableTestsParse : XCTestCase

@end

@implementation DXTableTestsParse

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testParseKeyValue
{
    NSString *const Keypath = @"items";
    NSString *const DXTableKeypath = @"@items";
    NSString *keypathResult = DXTableParseKeyValue(DXTableKeypath);
    XCTAssertNotNil(keypathResult, @"%@ must be parsed to regular keypath", DXTableKeypath);
    XCTAssertEqualObjects(keypathResult, Keypath, @"Providing keypath prefixed with @ must be parsed to the same keypath without @-prefix");

    NSString *const DXTableInnerKeypath = @"@.items";
    NSString *innerKeypathResult = DXTableParseKeyValue(DXTableInnerKeypath);
    XCTAssertNotNil(innerKeypathResult, @"%@ must be parsed to regular keypath", DXTableInnerKeypath);

    NSString *const StringValue = @"This is a title";
    NSString *valueResult = DXTableParseKeyValue(StringValue);
    XCTAssertNil(valueResult, @"%@ must be parsed to `nil`", StringValue);

    NSNumber *const NumberValue = @42;
    NSString *numberValueResult = DXTableParseKeyValue(NumberValue);
    XCTAssertNil(numberValueResult, @"%@ must be parsed to `nil`", NumberValue);

    NSDictionary *const DictValue = @{@"key": @42};
    NSString *dictValueResult = DXTableParseKeyValue(DictValue);
    XCTAssertNil(dictValueResult, @"%@ must be parsed to `nil`", DictValue);
}

- (void)testParseBindingsIsDefaultMode
{
    NSString *stringValue = @"Just a string value";
    BOOL stringValueResult = DXTableParseIsDefaultMode(stringValue);
    XCTAssertTrue(stringValueResult, @"Providing string as a value imply default binding mode");

    NSNumber *numberValue = @42;
    BOOL numberValueResult = DXTableParseIsDefaultMode(numberValue);
    XCTAssertTrue(numberValueResult, @"Providing number as a value imply default binding mode");

    NSArray *arrayValue = @[@"string", @123];
    BOOL arrayValueResult = DXTableParseIsDefaultMode(arrayValue);
    XCTAssertTrue(arrayValueResult, @"Providing array as a value imply default binding mode");

    NSDictionary *plainDictValue = @{@"key": @43};
    BOOL plainDictValueResult = DXTableParseIsDefaultMode(plainDictValue);
    XCTAssertTrue(plainDictValueResult, @"Providing dict without 'mode' key as a value imply default binding mode");

    NSDictionary *dictWithModeKeyValue = @{DXTableKeypathKey: @"titles",
                                DXTableModeKey: DXTableToViewMode};
    BOOL dictWithModeKeyValueResult = DXTableParseIsDefaultMode(dictWithModeKeyValue);
    XCTAssertFalse(dictWithModeKeyValueResult, @"Providing dictionary value with 'mode' key must override default binding mode");
}

- (void)testparseBindingsIsToViewMode
{
    NSString *stringValue = @"Yet another string";
    BOOL stringResult = DXTableParseIsToViewMode(stringValue);
    XCTAssertFalse(stringResult, @"String must be treated as not ToView mode");

    NSDictionary *dictWithFromViewMode = @{DXTableModeKey: DXTableFromViewMode};
    BOOL dictWithFromViewModeResult = DXTableParseIsToViewMode(dictWithFromViewMode);
    XCTAssertFalse(dictWithFromViewModeResult, @"Dict with FromView mode must be treated as not ToView mode");

    NSDictionary *dictWithToViewMode = @{DXTableModeKey: DXTableToViewMode};
    BOOL dictWithToViewModeResult = DXTableParseIsToViewMode(dictWithToViewMode);
    XCTAssertTrue(dictWithToViewModeResult, @"Dict with FromView mode must be treated as ToView mode");
}

- (void)testparseBindingsIsFromViewMode
{
    NSString *stringValue = @"Yet another string";
    BOOL stringResult = DXTableParseIsFromViewMode(stringValue);
    XCTAssertFalse(stringResult, @"String must be treated as not FromView mode");

    NSDictionary *dictWithToViewMode = @{DXTableModeKey: DXTableToViewMode};
    BOOL dictWithToViewModeResult = DXTableParseIsFromViewMode(dictWithToViewMode);
    XCTAssertFalse(dictWithToViewModeResult, @"Dict with ToView mode must be treated as not FromView mode");

    NSDictionary *dictWithFromViewMode = @{DXTableModeKey: DXTableFromViewMode};
    BOOL dictWithFromViewModeResult = DXTableParseIsFromViewMode(dictWithFromViewMode);
    XCTAssertTrue(dictWithFromViewModeResult, @"Dict with FromView mode must be treated as FromView mode");
}

@end
