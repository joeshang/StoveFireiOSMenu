//
//  DXEOrderManager.m
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 9/17/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "DXEOrderManager.h"
#import "DXEOrderItem.h"
#import "DXEDataManager.h"
#import "DXEDishItem.h"

@interface DXEOrderManager ()

@end

@implementation DXEOrderManager

+ (DXEOrderManager *)sharedInstance
{
    static DXEOrderManager *sharedManager = nil;
    
    if (sharedManager == nil)
    {
        sharedManager = [[super allocWithZone:nil] init];
        
        sharedManager.totalCount = [NSNumber numberWithInt:0];
        sharedManager.cartList = [[NSMutableArray alloc] init];
        sharedManager.orderList = [[NSMutableArray alloc] init];
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
    return [self mutableArrayValueForKey:NSStringFromSelector(@selector(cartList))];
}

- (NSMutableArray *)order
{
    return [self mutableArrayValueForKey:NSStringFromSelector(@selector(orderList))];
}

#pragma mark - KVC

- (void)insertObject:(DXEOrderItem *)object inCartListAtIndex:(NSUInteger)index
{
    [object addObserver:self
             forKeyPath:NSStringFromSelector(@selector(count))
                options:NSKeyValueObservingOptionNew
                context:nil];
    DXEDishItem *dish = [[DXEDataManager sharedInstance].dishes objectForKey:object.itemid];
    dish.inCart = YES;
    self.totalCount = [NSNumber numberWithInteger:[self.totalCount integerValue] + [object.count integerValue]];
    [self.cartList insertObject:object atIndex:index];
}

- (void)removeObjectFromCartListAtIndex:(NSUInteger)index
{
    DXEOrderItem *object = [self.cartList objectAtIndex:index];
    [object removeObserver:self
                forKeyPath:NSStringFromSelector(@selector(count))];
    DXEDishItem *dish = [[DXEDataManager sharedInstance].dishes objectForKey:object.itemid];
    dish.inCart = NO;
    self.totalCount = [NSNumber numberWithInteger:[self.totalCount integerValue] - [object.count integerValue]];
    [self.cartList removeObjectAtIndex:index];
}

- (void)insertObject:(DXEOrderItem *)object inOrderListAtIndex:(NSUInteger)index
{
    [object addObserver:self
             forKeyPath:NSStringFromSelector(@selector(progress))
                options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                context:nil];
    self.totalCount = [NSNumber numberWithInteger:[self.totalCount integerValue] + [object.count integerValue]];
    
    [self.orderList insertObject:object atIndex:index];
}

- (void)removeObjectFromOrderListAtIndex:(NSUInteger)index
{
    DXEOrderItem *object = [self.cartList objectAtIndex:index];
    [object removeObserver:self
                forKeyPath:NSStringFromSelector(@selector(progress))];
    self.totalCount = [NSNumber numberWithInteger:[self.totalCount integerValue] - [object.count integerValue]];
    
    [self.orderList removeObjectAtIndex:index];
}

#pragma mark - Notification

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(count))])
    {
        int totalCount = 0;
        totalCount += [[self valueForKeyPath:@"cartList.@sum.count"] intValue];
        totalCount += [[self valueForKeyPath:@"orderList.@sum.count"] intValue];
        self.totalCount = [NSNumber numberWithInt:totalCount];
    }
    else if ([keyPath isEqualToString:NSStringFromSelector(@selector(progress))])
    {
        NSNumber *old = change[NSKeyValueChangeOldKey];
        NSNumber *new = change[NSKeyValueChangeNewKey];
        
        if (old == nil || [old integerValue] != [new integerValue])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kDXEDidUpdateOrderProgressNotification object:nil];
        }
    }
}

@end
