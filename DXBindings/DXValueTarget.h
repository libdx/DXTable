//
//  ValueTarget.h
//  Bindings
//
//  Created by Alexander Ignatenko on 17/05/14.
//  Copyright (c) 2014 Alexander Ignatenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DXValueTarget : NSObject

@property (nonatomic) id value;

@property (nonatomic, copy) void (^valueChanged)(id value, UIEvent *event);

- (void)becomeTargetOfControl:(UIControl *)control;
- (void)resignTargetOfControl:(UIControl *)control;

@end
