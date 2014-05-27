//
//  DXTableSection.h
//  Pieces
//
//  Created by Alexander Ignatenko on 22/05/14.
//  Copyright (c) 2014 Alexander Ignatenko. All rights reserved.
//

#import "DXTableItem.h"

extern NSString *const DXTableRowsKey;

@interface DXTableSection : DXTableItem

@property (nonatomic, readonly) NSArray *allRows;
@property (nonatomic, readonly) NSArray *rows;

- (NSInteger)numberOfRows;

@end
