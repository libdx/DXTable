//
//  DXKVOInfo.h
//  Pieces
//
//  Created by Alexander Ignatenko on 31/05/14.
//  Copyright (c) 2014 Alexander Ignatenko. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, DXKVOType) {
    DXKVOTypeUndefined,
    DXKVOTypeObject,
    DXKVOTypeArray,
    DXKVOTypeOrderedSet,
    DXKVOTypeSet
};

@interface DXKVOInfo : NSObject

@property (nonatomic, weak) id object;
@property (nonatomic, copy) NSString *keypath;
@property (nonatomic) NSKeyValueObservingOptions options;
@property (nonatomic) SEL action;
@property (nonatomic, copy) void (^block)(id observer, id object, NSDictionary *change);
@property (nonatomic, readonly) DXKVOType type; // `DXKVOTypeObject` by default

@end
