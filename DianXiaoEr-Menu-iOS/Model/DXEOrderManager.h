//
//  DXEOrderManager.h
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 9/17/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DXEOrderManager : NSObject

@property (nonatomic, strong) NSMutableArray *cartList;
@property (nonatomic, strong) NSMutableArray *todoList;
@property (nonatomic, strong) NSMutableArray *doingList;
@property (nonatomic, strong) NSMutableArray *doneList;

+ (DXEOrderManager *)sharedInstance;

@end
