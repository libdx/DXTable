//
//  EventViewModel.h
//  Pieces
//
//  Created by Alexander Ignatenko on 23/05/14.
//  Copyright (c) 2014 Alexander Ignatenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EventViewModel : NSObject

@property (nonatomic, copy) NSString *title;

@property (nonatomic) NSDate *dueDate;

@property (nonatomic) BOOL showsDueDatePicker;

@property (nonatomic, copy) NSArray *things;

- (void)addThing;

- (void)toggleShowDueDatePicker;

@end
