//
//  DXViewDelegate.m
//  DXTable
//
//  Created by Alexander Ignatenko on 18/06/14.
//  Copyright (c) 2014 Alexander Ignatenko. All rights reserved.
//

#import "DXViewDelegate.h"

@interface DXViewDelegate ()

@property (nonatomic) id value;

@end

@implementation DXViewDelegate

#pragma mark - <UITextViewDelegate>

- (void)textViewDidChange:(UITextView *)textView
{
    self.value = textView.text;
    NSAssert(self.valueChanged, @"valueChanged block is NULL, provide valueChanged block");
    self.valueChanged(self.value);
}

@end
