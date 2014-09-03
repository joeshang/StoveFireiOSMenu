//
//  DXEDishDataManager.m
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 9/2/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "DXEDishDataManager.h"
#import "NSObject+ObjectMap.h"
#import "DXEDishItem.h"
#import "DXEDishClass.h"

#define DXE_TEST_DISH_DATA

@interface DXEDishDataManager ()

@property (nonatomic, strong) NSMutableArray *dishClasses;

- (void)updateDishClassFromJsonData:(NSData *)jsonData;
- (void)updateDishItemFromJsonData:(NSData *)jsonData;

#ifdef DXE_TEST_DISH_DATA
- (NSData *)dishClassDataOfTestingNew;
- (NSData *)dishClassDataOfTestingUpdateAndAdd;
- (NSData *)dishItemDataOfTestingNew;
- (NSData *)dishItemDataOfTestingUpdateAndAdd;
#endif

@end

@implementation DXEDishDataManager

+ (DXEDishDataManager *)sharedInstance
{
    static DXEDishDataManager *sharedManager = nil;
    
    if (sharedManager == nil)
    {
        sharedManager = [[super allocWithZone:nil] init];

#ifdef DXE_TEST_DISH_DATA
        [sharedManager updateDishClassFromJsonData:[sharedManager dishClassDataOfTestingNew]];
        [sharedManager updateDishClassFromJsonData:[sharedManager dishClassDataOfTestingUpdateAndAdd]];
        [sharedManager updateDishItemFromJsonData:[sharedManager dishItemDataOfTestingNew]];
        [sharedManager updateDishItemFromJsonData:[sharedManager dishItemDataOfTestingUpdateAndAdd]];
#endif
    }
    
    return sharedManager;
}

- (void)updateDishClassFromJsonData:(NSData *)jsonData
{
    NSArray *updateClasses = [NSObject arrayOfType:[DXEDishClass class] FromJSONData:jsonData];

    if ([updateClasses count] == 0)
    {
        return;
    }
    
    NSMutableArray *newClasses = [NSMutableArray arrayWithArray:updateClasses];
    if (self.dishClasses == nil)
    {
        self.dishClasses = newClasses;
    }
    else
    {
        for (DXEDishClass *update in updateClasses)
        {
            if (update.classid == nil)
            {
                NSLog(@"[DXEDishDataManager] empty classid in DishClass");
                [newClasses removeObject:update];
                continue;
            }
            
            [self.dishClasses enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop){
                DXEDishClass *current = (DXEDishClass *)obj;
                // 更新菜类信息
                if ([update.classid integerValue] == [current.classid integerValue])
                {
                    [current updateByNewObject:update];
                    [newClasses removeObject:update];
                    *stop = YES;
                }
            }];
        }
       
        // 添加菜类信息
        [self.dishClasses addObjectsFromArray:newClasses];
    }
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"showSequence" ascending:YES];
    [self.dishClasses sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    if ([newClasses count] != 0)
    {
        // 对于新增菜类请求此类的菜品
    }
    
#ifdef DXE_TEST_DISH_DATA
    [self.dishClasses enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop){
        DXEDishClass *current = (DXEDishClass *)obj;
        NSLog(@"%@", [current JSONString]);
    }];
#endif
}

- (void)updateDishItemFromJsonData:(NSData *)jsonData
{
    NSArray *updateItems = [NSObject arrayOfType:[DXEDishItem class] FromJSONData:jsonData];
    
    if ([updateItems count] == 0)
    {
        return;
    }
    
    for (DXEDishItem *update in updateItems)
    {
        if (update.classid == nil && update.itemid == nil)
        {
            NSLog(@"[DXEDishDataManager] empty classid/itemid in DishItem");
            continue;
        }
        
        [self.dishClasses enumerateObjectsUsingBlock:^(DXEDishClass *class, NSUInteger classIndex, BOOL *stop){
            if ([update.classid integerValue] == [class.classid integerValue])
            {
                *stop = YES;
                
                if (class.dishes == nil)
                {
                    class.dishes = [NSMutableArray arrayWithObject:update];
                }
                else
                {
                    [class.dishes enumerateObjectsUsingBlock:^(DXEDishItem *item, NSUInteger itemIndex, BOOL *stop){
                        if ([update.itemid integerValue] == [item.itemid integerValue])
                        {
                            [item updateByNewObject:update];
                        }
                        else
                        {
                            if ([item isEqual:[class.dishes lastObject]])
                            {
                                [class.dishes addObject:update];
                            }
                        }
                    }];
                }
                
                NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"showSequence" ascending:YES];
                [class.dishes sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
            }
            else
            {
                // 没有匹配的菜类
                if (classIndex == [self.dishClasses count])
                {
                    NSLog(@"[DXEDishDataManager] invalid classid(%@) in DishItem: itemid = %@, name = %@", update.classid, update.itemid, update.name);
                }
            }
        }];
    }
}

#ifdef DXE_TEST_DISH_DATA

#define kDXEDishClassName   @[@"前菜", @"沙拉", @"刺身", @"寿司", @"主菜", @"炸物", @"烤物", @"铁板烧", @"煮物", @"蒸物"]

- (NSData *)dishClassDataOfTestingNew
{
    NSArray *names = kDXEDishClassName;
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[names count]];
    for (NSUInteger i = 0; i < [names count]; i++)
    {
        DXEDishClass *class = [[DXEDishClass alloc] init];
        class.classid = [NSNumber numberWithInteger:i];
        class.showSequence = [NSNumber numberWithInteger:i + 1];
        class.name = [names objectAtIndex:i];
        class.imageKey = [NSString stringWithFormat:@"0_%ld_%.0f", i, [[NSDate date] timeIntervalSince1970]];
        [array addObject:class];
    }
    
    NSLog(@"%@", [array JSONString]);
    
    return [array JSONData];
}

- (NSData *)dishClassDataOfTestingUpdateAndAdd
{
    DXEDishClass *vip = [[DXEDishClass alloc] init];
    vip.classid = [NSNumber numberWithInteger:10];
    vip.showSequence = [NSNumber numberWithInteger:0];
    vip.name = @"会员";
    vip.imageKey = [NSString stringWithFormat:@"0_10_%.0f", [[NSDate date] timeIntervalSince1970]];
    
    DXEDishClass *front = [[DXEDishClass alloc] init];
    front.classid = [NSNumber numberWithInteger:0];
    front.showSequence = [NSNumber numberWithInteger:2];
    
    DXEDishClass *salad = [[DXEDishClass alloc] init];
    salad.classid = [NSNumber numberWithInteger:1];
    salad.showSequence = [NSNumber numberWithInteger:1];
    
    NSArray *array = [NSArray arrayWithObjects:vip, front, salad, nil];
    NSLog(@"%@", [array JSONString]);
    
    return [array JSONData];
}

- (NSData *)dishItemDataOfTestingNew
{
    NSArray *names = kDXEDishClassName;
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[names count] * 10];
    for (NSUInteger i = 0; i < [names count]; i++)
    {
        NSUInteger count = 8 + arc4random() % 6;
        for (NSUInteger j = 0; j < count; j++)
        {
            DXEDishItem *item = [[DXEDishItem alloc] init];
            item.itemid = [NSNumber numberWithInteger:i * 100 + j];
            item.classid = [NSNumber numberWithInteger:i];
            item.name = [NSString stringWithFormat:@"%@j", [names objectAtIndex:i]];
            item.imageKey = [NSString stringWithFormat:@"1_%ld_%.0f", j, [[NSDate date] timeIntervalSince1970]];
            item.showSequence = [NSNumber numberWithInteger:j + 1];
            item.price = [NSNumber numberWithInteger:20 + arc4random() % 100];
            item.like = [NSNumber numberWithInteger:1000 + arc4random() % 5000];
            item.ingredient = @"此物只应天上有，人间能够几回尝，此时不尝何时尝？原料顶级棒，安全放心，注意注意，前方高能预警，核能预警！巨美味巨好吃，嘿咻嘿咻北鼻够~";
            item.soldout = [NSNumber numberWithBool:NO];
            item.inCart = nil;
            [array addObject:item];
        }
    }
    
    return [array JSONData];
}

- (NSData *)dishItemDataOfTestingUpdateAndAdd
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:20];
    NSUInteger count = 8 + arc4random() % 6;
    for (NSUInteger j = 0; j < count; j++)
    {
        DXEDishItem *item = [[DXEDishItem alloc] init];
        item.itemid = [NSNumber numberWithInteger:1000 + j];
        item.classid = [NSNumber numberWithInteger:10];
        item.imageKey = [NSString stringWithFormat:@"1_%ld_%.0f", j, [[NSDate date] timeIntervalSince1970]];
        item.showSequence = [NSNumber numberWithInteger:j + 1];
        item.price = [NSNumber numberWithInteger:20 + arc4random() % 100];
        item.like = [NSNumber numberWithInteger:1000 + arc4random() % 5000];
        item.ingredient = @"此物只应天上有，人间能够几回尝，此时不尝何时尝？原料顶级棒，安全放心，注意注意，前方高能预警，核能预警！巨美味巨好吃，嘿咻嘿咻北鼻够~";
        item.soldout = [NSNumber numberWithBool:NO];
        item.inCart = nil;
        [array addObject:item];
    }
    
    DXEDishItem *update = [[DXEDishItem alloc] init];
    update.itemid = [NSNumber numberWithInteger:0];
    update.classid = [NSNumber numberWithInteger:0];
    update.price = [NSNumber numberWithInteger:88];
    [array addObject:update];
    
    return [array JSONData];
}

#endif

@end
