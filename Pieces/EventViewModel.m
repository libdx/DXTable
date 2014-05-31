//
//  EventViewModel.m
//  Pieces
//
//  Created by Alexander Ignatenko on 23/05/14.
//  Copyright (c) 2014 Alexander Ignatenko. All rights reserved.
//

#import "EventViewModel.h"

static NSDate *nextMonth()
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.month = 1;
    return [calendar dateByAddingComponents:components toDate:[NSDate date] options:0];
}

@implementation EventViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _dueDate = nextMonth();
    }
    return self;
}

- (NSArray *)things
{
    if (_things == nil) {
        _things = @[];
    }
    return _things.copy;
}

- (void)addThing
{
    NSMutableArray *things = [self mutableArrayValueForKey:@"things"];
    NSDictionary *thing = @{@"name": [NSDate date].description};
    [things addObject:thing];
}

- (void)toggleShowDueDatePicker
{
    self.showsDueDatePicker = !self.showsDueDatePicker;
    NSLog(@"%@: %@", NSStringFromSelector(_cmd), @(self.showsDueDatePicker));
}

@end
