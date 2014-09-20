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
@property (nonatomic, strong) NSMutableArray *todoList;
@property (nonatomic, strong) NSMutableArray *doingList;
@property (nonatomic, strong) NSMutableArray *doneList;

+ (DXEOrderManager *)sharedInstance;

- (NSMutableArray *)cart;
- (NSMutableArray *)todo;
- (NSMutableArray *)doing;
- (NSMutableArray *)done;

- (void)insertObject:(DXEDishItem *)object inCartListAtIndex:(NSUInteger)index;
- (void)removeObjectFromCartListAtIndex:(NSUInteger)index;
- (void)insertObject:(DXEDishItem *)object inTodoListAtIndex:(NSUInteger)index;
- (void)removeObjectFromTodoListAtIndex:(NSUInteger)index;
- (void)insertObject:(DXEDishItem *)object inDoingListAtIndex:(NSUInteger)index;
- (void)removeObjectFromDoingListAtIndex:(NSUInteger)index;
- (void)insertObject:(DXEDishItem *)object inDoneListAtIndex:(NSUInteger)index;
- (void)removeObjectFromDoneListAtIndex:(NSUInteger)index;

@end
