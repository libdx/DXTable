//
//  DXTableParse.m
//  DXTable
//
//  Created by Alexander Ignatenko on 29/06/14.
//  Copyright (c) 2014 Alexander Ignatenko. All rights reserved.
//

#import "DXTableParse.h"
#import "DXTableItem.h"

static NSString *const DXKeypathPrefix = @"@";
static NSString *const DXInnerKeyPathPrefix = @"@.";

NSString *DXTableParseKeyValue(id value)
{
    NSString *res;
    // if value is dictionary that represends keypath and binding process keypath in dictionary as a value
    if ([value isKindOfClass:[NSDictionary class]]) {
        value = value[DXTableKeypathKey];
    }

    if ([value isKindOfClass:[NSString class]]) {
        NSString *string = value;

        // value which contain method signature that accept arguments is illegal
        if ([string hasSuffix:@":"]) {
            return nil;
        }

        for (NSString *prefix in @[DXInnerKeyPathPrefix, DXKeypathPrefix]) {
            if ([string hasPrefix:prefix]) {
                res = [string stringByReplacingOccurrencesOfString:prefix withString:@""];
                break;
            }
        }
    }
    return res;
}

BOOL DXTableParseIsInnerKeypath(id value)
{
    BOOL res = NO;
    NSString *keypath = DXTableParseKeyValue(value);
    if (keypath) {
        NSString *string = value;
        res = [string hasPrefix:DXInnerKeyPathPrefix];
    }
    return res;
}

BOOL DXTableParseIsDefaultMode(id value)
{
    // dict with DXTableModeKey ("mode") key overrides default binding mode
    BOOL res = YES;
    if ([value isKindOfClass:[NSDictionary class]]) {
        if (value[DXTableModeKey] != nil) {
            res = NO;
        }
    }
    return res;
}

BOOL DXTableParseIsToViewMode(id value)
{
    if (![value isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    NSDictionary *dict = value;
    return [dict[DXTableModeKey] isEqualToString:DXTableToViewMode];
}

BOOL DXTableParseIsFromViewMode(id value)
{
    if (![value isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    NSDictionary *dict = value;
    return [dict[DXTableModeKey] isEqualToString:DXTableFromViewMode];
}
