//
//  DXViewDelegate.h
//  DXTable
//
//  Created by Alexander Ignatenko on 18/06/14.
//  Copyright (c) 2014 Alexander Ignatenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DXViewDelegate : NSObject <UITextViewDelegate>

@property (nonatomic, copy) void (^valueChanged)(id value);

@end
