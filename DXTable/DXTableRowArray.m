//
//  DXTableRowArray.m
//  Pieces
//
//  Created by Alexander Ignatenko on 30/05/14.
//  Copyright (c) 2014 Alexander Ignatenko. All rights reserved.
//

#import "DXTableRowArray.h"
#import "DXTableRow.h"

@implementation DXTableRowArray

@synthesize array = _array;

- (instancetype)initWithArray:(NSArray *)array
{
    self = [super init];
    if (self) {
        _array = array;
    }
    return self;
}

- (id)objectAtIndexedSubscript:(NSUInteger)idx
{
    if (idx >= self.count) {
        [NSException raise:NSRangeException
                    format:@"%u is out of range [0..%u]", idx, self.count - 1];
    }
    // TODO: make optimisations
    NSInteger repeatCount = 0;
    DXTableRow *row;
    for (row in self.array) {
        repeatCount += row.repeatCount;
        if ((NSInteger)idx - repeatCount <= -1) {
            break;
        }
    }
    return row;
}

- (NSIndexSet *)indexesOfRow:(DXTableRow *)row
{
    // TODO: Cover by tests
    // actual index of given `row` in the array
    NSInteger index = [self.array indexOfObject:row];

    // repeat counts representation of rows
    // for non-repeatable rows value of repeatCount is always 1
    NSArray *counts = [self.array valueForKeyPath:@"repeatCount"];

    // FIXME: what if repeatCount of a given `row` equals 0 ? should return `nil` ?

    // sliceCount is a number of elements (cells) that appear before the given `row`
    // [1, 0, 5, 1] if index = 2 => sliceCount = 1
    // [1, 1, 7, 1] if index = 2 => sliceCount = 2
    // [0, 1, 3, 1] if index = 2 => sliceCount = 1
    NSInteger sliceCount = [[[counts subarrayWithRange:NSMakeRange(0, index)]
                             valueForKeyPath:@"@sum.self"] integerValue];

    // return index set that starts with number of element that appear before given `row`
    // and length of repeatCount of `row`
    return [NSIndexSet indexSetWithIndexesInRange:
            NSMakeRange(sliceCount, row.repeatCount)];
}

- (NSUInteger)count
{
    return [[self.array valueForKeyPath:@"@sum.repeatCount"] unsignedIntegerValue];
}

@end
