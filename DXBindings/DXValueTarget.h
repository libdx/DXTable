//
//  ValueTarget.h
//  Bindings
//
//  Created by Alexander Ignatenko on 17/05/14.
//  Copyright (c) 2014 Alexander Ignatenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DXValueTarget : NSObject

@property (nonatomic) id value;

@property (nonatomic, copy) void (^valueChanged)(id value, UIEvent *event);

/// map in format @{NSStringFromClass([UIStepper class]): @"value", …}
@property (nonatomic, copy) NSDictionary *keypathByControlMap;

/**
 Designated initializer.
 @map NSDictionary object with class name as a key and keypath for retrieving value from control as a value.
 */
- (instancetype)initWithKeypathByControlMap:(NSDictionary *)map;

- (void)becomeTargetOfControl:(UIControl *)control;
- (void)resignTargetOfControl:(UIControl *)control;

@end
