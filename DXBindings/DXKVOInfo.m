//
//  DXKVOInfo.m
//  Pieces
//
//  Created by Alexander Ignatenko on 31/05/14.
//  Copyright (c) 2014 Alexander Ignatenko. All rights reserved.
//

#import "DXKVOInfo.h"

@implementation DXKVOInfo

- (DXKVOType)type
{
    DXKVOType type;
    if ([self.object isKindOfClass:[NSArray class]]) {
        type = DXKVOTypeArray;
    } else if ([self.object isKindOfClass:[NSOrderedSet class]]) {
        type = DXKVOTypeOrderedSet;
    } else if ([self.object isKindOfClass:[NSSet class]]) {
        type = DXKVOTypeSet;
    } else if ([self.object isKindOfClass:[NSObject class]]) {
        type = DXKVOTypeObject;
    }
    return type;
}

@end
