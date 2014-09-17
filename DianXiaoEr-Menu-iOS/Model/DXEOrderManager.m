//
//  DXEOrderManager.m
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 9/17/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "DXEOrderManager.h"

@interface DXEOrderManager ()

@property (nonatomic, strong) NSMutableArray *cartList;
@property (nonatomic, strong) NSMutableArray *todoList;
@property (nonatomic, strong) NSMutableArray *doingList;
@property (nonatomic, strong) NSMutableArray *doneList;

@end

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

#pragma mark - Proxy for KVO

- (NSMutableArray *)cart
{
    return [self mutableArrayValueForKey:@"cartList"];
}

- (NSMutableArray *)todo
{
    return [self mutableArrayValueForKey:@"todoList"];
}

- (NSMutableArray *)doing
{
    return [self mutableArrayValueForKey:@"doingList"];
}

- (NSMutableArray *)done
{
    return [self mutableArrayValueForKey:@"doneList"];
}

#pragma mark - KVC

- (void)insertObject:(DXEDishItem *)object inCartListAtIndex:(NSUInteger)index
{
    [self.cartList insertObject:object atIndex:index];
}

- (void)removeObjectFromCartListAtIndex:(NSUInteger)index
{
    [self.cartList removeObjectAtIndex:index];
}

- (void)insertObject:(DXEDishItem *)object inTodoListAtIndex:(NSUInteger)index
{
    [self.todoList insertObject:object atIndex:index];
}

- (void)removeObjectFromTodoListAtIndex:(NSUInteger)index
{
    [self.todoList removeObjectAtIndex:index];
}

- (void)insertObject:(DXEDishItem *)object inDoingListAtIndex:(NSUInteger)index
{
    [self.doingList insertObject:object atIndex:index];
}

- (void)removeObjectFromDoingListAtIndex:(NSUInteger)index
{
    [self.doingList removeObjectAtIndex:index];
}

- (void)insertObject:(DXEDishItem *)object inDoneListAtIndex:(NSUInteger)index
{
    [self.doneList insertObject:object atIndex:index];
}

- (void)removeObjectFromDoneListAtIndex:(NSUInteger)index
{
    [self.doneList removeObjectAtIndex:index];
}

@end
