//
//  DXTableRowArrayTests.m
//  DXTable
//
//  Created by Alexander Ignatenko on 04/07/14.
//  Copyright (c) 2014 Alexander Ignatenko. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "DXTableRowArray.h"

@interface MockRow : NSObject

- (instancetype)initWithRepeatCount:(NSInteger)repeatCount;

@property (nonatomic, readonly) NSInteger repeatCount;

- (void)changeRepeatCountTo:(NSInteger)repeatCount;

@end

@implementation MockRow

@synthesize repeatCount = _repeatCount;

- (instancetype)initWithRepeatCount:(NSInteger)repeatCount
{
    self = [super init];
    if (self) {
        _repeatCount = repeatCount;
    }
    return self;
}

- (void)changeRepeatCountTo:(NSInteger)repeatCount
{
    _repeatCount = repeatCount;
}

@end

@interface DXTableRowArrayTests : XCTestCase

@property (nonatomic) NSArray *array;
@property (nonatomic) DXTableRowArray *rowArray;

@end

@implementation DXTableRowArrayTests

- (void)setUp
{
    [super setUp];

    self.array = @[[[MockRow alloc] initWithRepeatCount:1],
                   [[MockRow alloc] initWithRepeatCount:5],
                   [[MockRow alloc] initWithRepeatCount:0],
                   [[MockRow alloc] initWithRepeatCount:1]
                   ];

    self.rowArray = [[DXTableRowArray alloc] initWithArray:self.array];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testCount
{
    XCTAssertTrue(self.rowArray.count == 7, @"expects count to take into account repeatCount property of DXTableRow object");
}

- (void)testIndexedSubscript
{
    XCTAssertEqualObjects(self.rowArray.array, self.array, @"expects array property to be contains same objects as initial array");

    XCTAssertNotEqualObjects(self.rowArray[3], self.array[3], @"expects subscript to take into account repeatCount of row objects");

    XCTAssertEqualObjects(self.rowArray[3], self.array[1], @"expects subscript of 3 to return second row from array");

    XCTAssert(self.rowArray[6], @"expects subscript of 6 to not be beyond of row array bounds");
    XCTAssertThrows(self.rowArray[7], @"expects subscript of 7 to be beyond of row array bounds");
}

- (void)testIndexesOfRow
{
    NSIndexSet *rowIndexes0 = [self.rowArray indexesOfRow:self.array[0]];
    NSIndexSet *rowIndexes1 = [self.rowArray indexesOfRow:self.array[1]];
    NSIndexSet *rowIndexes2 = [self.rowArray indexesOfRow:self.array[2]];
    NSIndexSet *rowIndexes3 = [self.rowArray indexesOfRow:self.array[3]];

    XCTAssertEqual(rowIndexes0.firstIndex, 0, @"expects first index of 0th row to be 0");
    XCTAssertEqual(rowIndexes0.lastIndex, 0, @"expects last index of 0th row to be 0");

    XCTAssertEqual(rowIndexes1.firstIndex, 1, @"expects last index of 1st row to be 1");
    XCTAssertEqual(rowIndexes1.lastIndex, 5, @"expects last index of 1st row to be 5");

    XCTAssertEqual(rowIndexes2.firstIndex, NSNotFound, @"expects last index of 2nd row to be Not Found");
    XCTAssertEqual(rowIndexes2.lastIndex, NSNotFound, @"expects last index of 2nd row to be Not Found");

    XCTAssertEqual(rowIndexes3.firstIndex, 6, @"expects last index of 3rd row to be 6");
    XCTAssertEqual(rowIndexes3.lastIndex, 6, @"expects last index of 3rd row to be 6");

}

@end
