//
//  SFOrderManager.h
//  StoveFireiOSMenu
//
//  Created by Joe Shang on 9/17/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SFOrderItem;

@interface SFOrderManager : NSObject

@property (nonatomic, strong) NSNumber *totalCount;
@property (nonatomic, strong) NSMutableArray *cartList;
@property (nonatomic, strong) NSMutableArray *orderList;

+ (SFOrderManager *)sharedInstance;

- (NSMutableArray *)cart;
- (NSMutableArray *)order;

- (void)insertObject:(SFOrderItem*)object inCartListAtIndex:(NSUInteger)index;
- (void)removeObjectFromCartListAtIndex:(NSUInteger)index;
- (void)insertObject:(SFOrderItem *)object inOrderListAtIndex:(NSUInteger)index;
- (void)removeObjectFromOrderListAtIndex:(NSUInteger)index;

@end
