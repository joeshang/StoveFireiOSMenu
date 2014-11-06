//
//  SFOrderItem.m
//  StoveFireiOSMenu
//
//  Created by Joe Shang on 10/16/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "SFOrderItem.h"

@implementation SFOrderItem

- (id)init
{
    return [self initWithItemid:nil];
}

- (id)initWithItemid:(NSNumber *)itemid
{
    self = [super init];
    
    if (self)
    {
        _itemid = itemid;
        _count = [NSNumber numberWithInteger:1];
        _tradeid = [NSNumber numberWithInteger:-1];
        _progress = [NSNumber numberWithInt:SFDishProgressTodo];
    }
    
    return self;
}

@end
