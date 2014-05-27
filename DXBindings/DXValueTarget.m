//
//  ValueTarget.m
//  Bindings
//
//  Created by Alexander Ignatenko on 17/05/14.
//  Copyright (c) 2014 Alexander Ignatenko. All rights reserved.
//

#import "DXValueTarget.h"

static NSString *valueKeypathForControl(Class control)
{
    static NSDictionary *map;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        map = @{NSStringFromClass([UIStepper class]): @"value",
                NSStringFromClass([UISlider class]): @"value",
                NSStringFromClass([UIDatePicker class]): @"date",
                NSStringFromClass([UITextField class]): @"text",
                NSStringFromClass([UISwitch class]): @"on",
                NSStringFromClass([UIPageControl class]): @"currentPage"};
    });
    return map[NSStringFromClass(control)];
}

static UIControlEvents defaultEventsForControl(Class control)
{
    UIControlEvents events;
    if ([control isSubclassOfClass:[UITextField class]]) {
        events = UIControlEventAllEditingEvents;
    } else {
        events = UIControlEventValueChanged;
    }
    return events;
}

@implementation DXValueTarget

- (void)becomeTargetOfControl:(UIControl *)control
{
    [control addTarget:self
                action:@selector(controlChanged:withEvent:)
      forControlEvents:defaultEventsForControl([control class])];
}

- (void)controlChanged:(id)control withEvent:(UIEvent *)event
{
    self.value = [control valueForKeyPath:valueKeypathForControl([control class])];
    NSAssert(self.valueChanged, @"valueChanged block is NULL, provide valueChanged block");
    self.valueChanged(self.value, event);
}

@end
