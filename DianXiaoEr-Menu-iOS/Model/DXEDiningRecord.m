//
//  DXEDiningRecord.m
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 9/23/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "DXEDiningRecord.h"
#import "DXERecordDishItem.h"

@implementation DXEDiningRecord

- (id)init
{
    self = [super init];
    if (self)
    {
        [self setValue:NSStringFromClass([DXERecordDishItem class])
            forKeyPath:@"propertyArrayMap.dishes"];
    }
    return self;
}

@end
