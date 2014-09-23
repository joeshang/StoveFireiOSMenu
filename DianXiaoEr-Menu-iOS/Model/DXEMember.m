//
//  DXEUserDataManager.m
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 9/22/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "DXEMember.h"
#import "DXEDiningRecord.h"
#import "DXERecordDishItem.h"

@implementation DXEMember

- (id)init
{
    self = [super init];
    if (self)
    {
        [self setValue:NSStringFromClass([DXEDiningRecord class])
            forKeyPath:@"propertyArrayMap.records"];
    }
    return self;
}

@end
