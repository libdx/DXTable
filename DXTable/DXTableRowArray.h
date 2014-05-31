//
//  DXTableRowArray.h
//  Pieces
//
//  Created by Alexander Ignatenko on 30/05/14.
//  Copyright (c) 2014 Alexander Ignatenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DXTableRow;

@interface DXTableRowArray : NSObject

- (instancetype)initWithArray:(NSArray *)array;

@property (nonatomic, readonly) NSArray *array;

@property (nonatomic, readonly) NSUInteger count;

- (NSIndexSet *)indexesOfRow:(DXTableRow *)row;

- (DXTableRow *)objectAtIndexedSubscript:(NSUInteger)idx;

@end
