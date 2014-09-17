//
//  DXEDishItem.m
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 8/31/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "DXEDishItem.h"

@implementation DXEDishItem

- (id)init
{
    self = [super init];
    
    if (self)
    {
        _inCart = NO;
        _inFavor = NO;
        _count = 0;
        _tradeid = nil;
    }
    
    return self;
}

- (void)updateByNewObject:(DXEDishItem *)update
{
    if (update.name != nil)
    {
        self.name = [update.name copy];
    }
    
    if (update.englishName != nil)
    {
        self.englishName = [update.englishName copy];
    }
    
    if (update.imageKey != nil)
    {
        self.imageKey = [update.imageKey copy];
    }
    
    if (update.showSequence != nil)
    {
        self.showSequence = [update.showSequence copy];
    }
    
    if (update.price != nil)
    {
        self.price = [update.price copy];
    }
    
    if (update.favor != nil)
    {
        self.favor = [update.favor copy];
    }
    
    if (update.ingredient != nil)
    {
        self.ingredient = [update.ingredient copy];
    }
    
    if (update.soldout != nil)
    {
        self.soldout = [update.soldout copy];
    }
}

@end
