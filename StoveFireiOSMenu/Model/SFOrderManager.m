//
//  SFOrderManager.m
//  StoveFireiOSMenu
//
//  Created by Joe Shang on 9/17/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "SFOrderManager.h"
#import "SFOrderItem.h"
#import "SFDataManager.h"
#import "SFDishItem.h"

@interface SFOrderManager ()

@end

@implementation SFOrderManager

+ (SFOrderManager *)sharedInstance
{
    static SFOrderManager *sharedManager = nil;
    
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

- (void)insertObject:(SFOrderItem *)object inCartListAtIndex:(NSUInteger)index
{
    [object addObserver:self
             forKeyPath:NSStringFromSelector(@selector(count))
                options:NSKeyValueObservingOptionNew
                context:nil];
    SFDishItem *dish = [[SFDataManager sharedInstance].dishes objectForKey:object.itemid];
    dish.inCart = YES;
    self.totalCount = [NSNumber numberWithInteger:[self.totalCount integerValue] + [object.count integerValue]];
    [self.cartList insertObject:object atIndex:index];
}

- (void)removeObjectFromCartListAtIndex:(NSUInteger)index
{
    SFOrderItem *object = [self.cartList objectAtIndex:index];
    [object removeObserver:self
                forKeyPath:NSStringFromSelector(@selector(count))];
    SFDishItem *dish = [[SFDataManager sharedInstance].dishes objectForKey:object.itemid];
    dish.inCart = NO;
    self.totalCount = [NSNumber numberWithInteger:[self.totalCount integerValue] - [object.count integerValue]];
    [self.cartList removeObjectAtIndex:index];
}

- (void)insertObject:(SFOrderItem *)object inOrderListAtIndex:(NSUInteger)index
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
    SFOrderItem *object = [self.orderList objectAtIndex:index];
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
            [[NSNotificationCenter defaultCenter] postNotificationName:kSFDidUpdateOrderProgressNotification object:nil];
        }
    }
}

@end
