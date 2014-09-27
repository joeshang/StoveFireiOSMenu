//
//  DXEOrderManager.h
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 9/17/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DXEDishItem;

@interface DXEOrderManager : NSObject

@property (nonatomic, strong) NSNumber *totalCount;
@property (nonatomic, strong) NSMutableArray *cartList;
@property (nonatomic, strong) NSMutableArray *orderList;

+ (DXEOrderManager *)sharedInstance;

- (NSMutableArray *)cart;
- (NSMutableArray *)order;

- (void)insertObject:(DXEDishItem *)object inCartListAtIndex:(NSUInteger)index;
- (void)removeObjectFromCartListAtIndex:(NSUInteger)index;
- (void)insertObject:(DXEDishItem *)object inOrderListAtIndex:(NSUInteger)index;
- (void)removeObjectFromOrderListAtIndex:(NSUInteger)index;

@end