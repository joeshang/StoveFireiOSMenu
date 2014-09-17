//
//  DXEOrderManager.m
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 9/17/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "DXEOrderManager.h"

@implementation DXEOrderManager

+ (DXEOrderManager *)sharedInstance
{
    static DXEOrderManager *sharedManager = nil;
    
    if (sharedManager == nil)
    {
        sharedManager = [[super allocWithZone:nil] init];
        
        sharedManager.cartList = [[NSMutableArray alloc] init];
        sharedManager.todoList = [[NSMutableArray alloc] init];
        sharedManager.doingList = [[NSMutableArray alloc] init];
        sharedManager.doneList = [[NSMutableArray alloc] init];
    }
    
    return sharedManager;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    return [self sharedInstance];
}

@end
