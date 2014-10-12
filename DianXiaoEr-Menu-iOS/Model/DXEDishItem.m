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
        _inFavor = NO;
        _inCart = NO;
        _count = [NSNumber numberWithInteger:0];
        _tradeid = nil;
        _progress = nil;
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    DXEDishItem *copy = [[[self class] allocWithZone:zone] init];
    
    if (copy)
    {
        copy.itemid = [self.itemid copy];
        copy.classid = [self.classid copy];
        copy.name = [self.name copy];
        copy.englishName = [self.englishName copy];
        copy.imageKey = [self.imageKey copy];
        copy.thumbnailKey = [self.thumbnailKey copy];
        copy.showSequence = [self.showSequence copy];
        copy.price = [self.price copy];
        copy.favor = [self.favor copy];
        copy.ingredient = [self.ingredient copy];
        copy.soldout = [self.soldout copy];
        copy.inCart = self.inCart;
        copy.inFavor = self.inFavor;
        copy.count = [self.count copy];
        copy.tradeid = [self.tradeid copy];
    }
    
    return copy;
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
    
    if (update.thumbnailKey != nil)
    {
        self.thumbnailKey = [update.thumbnailKey copy];
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
