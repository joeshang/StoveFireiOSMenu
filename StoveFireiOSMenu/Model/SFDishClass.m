//
//  SFDishClass.m
//  StoveFireiOSMenu
//
//  Created by Joe Shang on 8/31/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "SFDishClass.h"

@implementation SFDishClass

- (id)init
{
    self = [super init];
    
    if (self)
    {
    }
    
    return self;
}

- (void)updateByNewObject:(SFDishClass *)update
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
}

@end
