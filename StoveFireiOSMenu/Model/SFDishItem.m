//
//  SFDishItem.m
//  StoveFireiOSMenu
//
//  Created by Joe Shang on 8/31/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "SFDishItem.h"

@implementation SFDishItem

- (id)init
{
    self = [super init];
    
    if (self)
    {
        _inFavor = NO;
        _inCart = NO;
    }
    
    return self;
}

- (void)updateByNewObject:(SFDishItem *)update
{
    if (update.name != nil)
    {
        self.name = update.name;
    }
    
    if (update.englishName != nil)
    {
        self.englishName = update.englishName;
    }
    
    if (update.imageKey != nil)
    {
        self.imageKey = update.imageKey;
    }
    
    if (update.thumbnailKey != nil)
    {
        self.thumbnailKey = update.thumbnailKey;
    }
    
    if (update.showSequence != nil)
    {
        self.showSequence = update.showSequence;
    }
    
    if (update.price != nil)
    {
        self.price = update.price;
    }
    
    if (update.favor != nil)
    {
        self.favor = update.favor;
    }
    
    if (update.ingredient != nil)
    {
        self.ingredient = update.ingredient;
    }
    
    if (update.soldout != nil)
    {
        self.soldout = update.soldout;
    }
    
    if (update.vip != nil)
    {
        self.vip = update.vip;
    }
}

@end
