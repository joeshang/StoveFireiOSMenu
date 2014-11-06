//
//  SFDiningRecord.m
//  StoveFireiOSMenu
//
//  Created by Joe Shang on 9/23/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "SFDiningRecord.h"
#import "SFRecordDishItem.h"

@implementation SFDiningRecord

- (id)init
{
    self = [super init];
    if (self)
    {
        [self setValue:NSStringFromClass([SFRecordDishItem class])
            forKeyPath:@"propertyArrayMap.dishes"];
    }
    return self;
}

@end
