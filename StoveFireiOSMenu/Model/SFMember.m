//
//  SFUserDataManager.m
//  StoveFireiOSMenu
//
//  Created by Joe Shang on 9/22/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "SFMember.h"
#import "SFDiningRecord.h"
#import "SFRecordDishItem.h"

@implementation SFMember

- (id)init
{
    self = [super init];
    if (self)
    {
        [self setValue:NSStringFromClass([SFDiningRecord class])
            forKeyPath:@"propertyArrayMap.records"];
    }
    return self;
}

@end
