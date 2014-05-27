//
//  TableViewCell.m
//  Pieces
//
//  Created by Alexander Ignatenko on 25/05/14.
//  Copyright (c) 2014 Alexander Ignatenko. All rights reserved.
//

#import "FieldCell.h"

@implementation FieldCell

- (void)prepareForReuse
{
    self.textField.text = nil;
    self.titleLabel.text = nil;
}

@end
