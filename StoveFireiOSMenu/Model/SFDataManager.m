//
//  SFDishDataManager.m
//  StoveFireiOSMenu
//
//  Created by Joe Shang on 9/2/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "SFDataManager.h"
#import "SFImageManager.h"
#import "AFNetworking.h"

@interface SFDataManager () < NSXMLParserDelegate >

@property (nonatomic, strong) AFHTTPSessionManager *httpManager;

@property (nonatomic, strong) NSString *responseContent;
@property (nonatomic, strong) NSXMLParser *tableParser;
@property (nonatomic, strong) NSXMLParser *dishClassParser;
@property (nonatomic, strong) NSXMLParser *dishItemParser;

- (void)updateDishClassFromJsonData:(NSData *)jsonData;
- (void)updateDishItemFromJsonData:(NSData *)jsonData;

#ifdef SF_UI_TEST
- (NSData *)dishClassDataOfTestingNew;
- (NSData *)dishClassDataOfTestingUpdateAndAdd;
- (NSData *)dishItemDataOfTestingNew;
- (NSData *)dishItemDataOfTestingUpdateAndAdd;
- (void)tableDataOfTesting;
#endif

@end

@implementation SFDataManager

#pragma mark - Singleton & init

+ (SFDataManager *)sharedInstance
{
    static SFDataManager *sharedManager = nil;
    
    if (sharedManager == nil)
    {
        sharedManager = [[super allocWithZone:nil] init];
    }
    
    return sharedManager;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    return [self sharedInstance];
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        NSURL *baseURL = [NSURL URLWithString:kSFWebServiceBaseURL];
        _httpManager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
        _httpManager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    }
    
    return self;
}

#pragma mark - Update data

- (void)updateDishClassFromJsonData:(NSData *)jsonData
{
    NSArray *updateClasses = [NSObject arrayOfType:[SFDishClass class] FromJSONData:jsonData];

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
        // 对于updateClasses中的数据，如果是错误项，则从数组中移除，如果是更新项，更新完也移除，最后剩下的全是新增项，全部加入dishClasses
        for (SFDishClass *update in updateClasses)
        {
            if (update.classid == nil)
            {
                NSLog(@"Error: empty classid in DishClass");
                [newClasses removeObject:update];
                continue;
            }
            
            [self.dishClasses enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop){
                SFDishClass *current = (SFDishClass *)obj;
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
}

- (void)updateDishItemFromJsonData:(NSData *)jsonData
{
    NSArray *updateItems = [NSObject arrayOfType:[SFDishItem class] FromJSONData:jsonData];
    
    if ([updateItems count] == 0)
    {
        return;
    }
    
    if (self.dishes == nil)
    {
        self.dishes = [NSMutableDictionary dictionaryWithCapacity:[updateItems count]];
    }
    
    for (SFDishItem *update in updateItems)
    {
        if (update.classid == nil || update.itemid == nil)
        {
            NSLog(@"Error: empty classid/itemid in DishItem -> %@", [update JSONString]);
            continue;
        }
        
        [self.dishClasses enumerateObjectsUsingBlock:^(SFDishClass *class, NSUInteger classIndex, BOOL *stop){
            // 根据菜品的classid跟itemid，加入到对应菜类的数组中或更新对应项
            if ([update.classid integerValue] == [class.classid integerValue])
            {
                *stop = YES;
                
                if (class.dishes == nil)
                {
                    class.dishes = [NSMutableArray arrayWithObject:update];
                    [self.dishes setObject:update forKey:update.itemid];
                }
                else
                {
                    [class.dishes enumerateObjectsUsingBlock:^(SFDishItem *item, NSUInteger itemIndex, BOOL *stop){
                        if ([update.itemid integerValue] == [item.itemid integerValue])
                        {
                            // 更新项
                            *stop = YES;
                            [item updateByNewObject:update];
                        }
                        else
                        {
                            if ([item isEqual:[class.dishes lastObject]])
                            {
                                // 新增项
                                [class.dishes addObject:update];
                                [self.dishes setObject:update forKey:update.itemid];
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
                if ([class isEqual:[self.dishClasses lastObject]])
                {
                    NSLog(@"Error: invalid classid DishItem -> %@", [update JSONString]);
                }
            }
        }];
    }
}

- (NSMutableArray *)imageKeys
{
    NSMutableArray *imageKeys = [[NSMutableArray alloc] init];
    
    if ([self.dishClasses count] == 0)
    {
        return nil;
    }
    
    for (SFDishClass *class in self.dishClasses)
    {
        if (class.imageKey != nil)
        {
            [imageKeys addObject:class.imageKey];
        }
        
        if (class.dishes && [class.dishes count] != 0)
        {
            for (SFDishItem *item in class.dishes)
            {
                if (item.imageKey != nil)
                {
                    [imageKeys addObject:item.imageKey];
                }
                
                if (item.thumbnailKey != nil)
                {
                    [imageKeys addObject:item.thumbnailKey];
                }
            }
        }
    }
    
    return imageKeys;
}

#pragma mark - Load Data

- (void)loadDataFromWeb
{
#ifdef SF_UI_TEST
    [self updateDishClassFromJsonData:[self dishClassDataOfTestingNew]];
    [self updateDishClassFromJsonData:[self dishClassDataOfTestingUpdateAndAdd]];
    [self updateDishItemFromJsonData:[self dishItemDataOfTestingNew]];
    [self updateDishItemFromJsonData:[self dishItemDataOfTestingUpdateAndAdd]];
    [self tableDataOfTesting];
#else
    
    [self.httpManager POST:@"GetTableList" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject){
        self.tableParser = (NSXMLParser *)responseObject;
        self.tableParser.delegate = self;
        [self.tableParser parse];
    } failure:^(NSURLSessionDataTask *task, NSError *error){
        NSLog(@"%@", error);
        [self sendErrorNotification:@"桌台数据"];
    }];
#endif
}

- (void)sendErrorNotification:(NSString *)string
{
    NSString *error = [NSString stringWithFormat:@"网络错误，获取%@失败，请检查网络后再次进入", string];
    NSDictionary *userInfo = @{ @"error": error };
    [[NSNotificationCenter defaultCenter] postNotificationName:kSFDidLoadingProgressNotification object:self userInfo:userInfo];
}

#pragma mark - NSXMLParserDelegate

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    self.responseContent = [NSString string];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.responseContent = [self.responseContent stringByAppendingString:string];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    if (parser == self.tableParser)
    {
        self.tables = [NSJSONSerialization JSONObjectWithData:[self.responseContent dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
        
        [self.httpManager POST:@"GetDishClasses" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject){
            self.dishClassParser = (NSXMLParser *)responseObject;
            self.dishClassParser.delegate = self;
            [self.dishClassParser parse];
        } failure:^(NSURLSessionDataTask *task, NSError *error){
            NSLog(@"%@", error);
            [self sendErrorNotification:@"菜类数据"];
        }];
    }
    else if (parser == self.dishClassParser)
    {
        [self updateDishClassFromJsonData:[self.responseContent dataUsingEncoding:NSUTF8StringEncoding]];
        
        [self.httpManager POST:@"GetDishItems" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject){
            self.dishItemParser = (NSXMLParser *)responseObject;
            self.dishItemParser.delegate = self;
            [self.dishItemParser parse];
        } failure:^(NSURLSessionDataTask *task, NSError *error){
            NSLog(@"%@", error);
            [self sendErrorNotification:@"菜品数据"];
        }];
    }
    else if (parser == self.dishItemParser)
    {
        [self updateDishItemFromJsonData:[self.responseContent dataUsingEncoding:NSUTF8StringEncoding]];
        [[SFImageManager sharedInstance] updateImageWithKeys:[self imageKeys]];
    }
}

#ifdef SF_UI_TEST

#define kSFDishClassName           @[@"前菜", @"沙拉", @"刺身", @"寿司", @"主菜", @"炸物", @"烤物", @"铁板烧", @"煮物", @"蒸物"]
#define kSFDishClassEnglishName    @[@"APPETIZER", @"SHALA", @"SASHIMI", @"SUSHI", @"ENTREE", @"FRIED", @"GRILLED", @"TEPPANYAKI", @"SIMMERED", @"STREAMING"]

- (NSData *)dishClassDataOfTestingNew
{
    NSArray *names = kSFDishClassName;
    NSArray *englishNames = kSFDishClassEnglishName;
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[names count]];
    for (int i = 0; i < [names count]; i++)
    {
        SFDishClass *class = [[SFDishClass alloc] init];
        class.classid = [NSNumber numberWithInteger:i];
        class.vip = [NSNumber numberWithBool:FALSE];
        class.showSequence = [NSNumber numberWithInteger:i + 1];
        class.name = [names objectAtIndex:i];
        class.englishName = [englishNames objectAtIndex:i];
        class.imageKey = [NSString stringWithFormat:@"0-%d@%.0f", i, [[NSDate date] timeIntervalSince1970]];
        [array addObject:class];
    }
    
    return [array JSONData];
}

- (NSData *)dishClassDataOfTestingUpdateAndAdd
{
    SFDishClass *vip = [[SFDishClass alloc] init];
    vip.classid = [NSNumber numberWithInteger:10];
    vip.vip = [NSNumber numberWithBool:TRUE];
    vip.showSequence = [NSNumber numberWithInteger:0];
    vip.name = @"会员";
    vip.englishName = @"VIP";
    vip.imageKey = [NSString stringWithFormat:@"0-10@%.0f", [[NSDate date] timeIntervalSince1970]];
    
    SFDishClass *front = [[SFDishClass alloc] init];
    front.classid = [NSNumber numberWithInteger:0];
    front.showSequence = [NSNumber numberWithInteger:2];
    
    SFDishClass *salad = [[SFDishClass alloc] init];
    salad.classid = [NSNumber numberWithInteger:1];
    salad.showSequence = [NSNumber numberWithInteger:1];
    
    NSArray *array = [NSArray arrayWithObjects:vip, front, salad, nil];
    
    return [array JSONData];
}

- (NSData *)dishItemDataOfTestingNew
{
    NSArray *names = kSFDishClassName;
    NSArray *englishNames = kSFDishClassEnglishName;
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[names count] * 10];
    for (int i = 0; i < [names count]; i++)
    {
        int count = 8 + arc4random() % 6;
        for (int j = 0; j < count; j++)
        {
            SFDishItem *item = [[SFDishItem alloc] init];
            item.itemid = [NSNumber numberWithInteger:i * 100 + j];
            item.classid = [NSNumber numberWithInteger:i];
            item.vip = [NSNumber numberWithBool:FALSE];
            item.name = [NSString stringWithFormat:@"%@_%d", [names objectAtIndex:i], j];
            item.englishName = [NSString stringWithFormat:@"%@_%d", [englishNames objectAtIndex:i], j];
            item.imageKey = [NSString stringWithFormat:@"1-%d@%.0f", j, [[NSDate date] timeIntervalSince1970]];
            item.thumbnailKey = [NSString stringWithFormat:@"2-%d@%.0f", j, [[NSDate date] timeIntervalSince1970]];
            item.showSequence = [NSNumber numberWithInteger:j + 1];
            item.price = [NSNumber numberWithFloat:20 + arc4random() % 100];
            item.favor = [NSNumber numberWithInteger:1000 + arc4random() % 5000];
            item.ingredient = @"此物只应天上有，人间能够几回尝，此时不尝何时尝？原料顶级棒，安全放心，注意注意，前方高能预警，核能预警！巨美味巨好吃，嘿咻嘿咻北鼻够~~\nVery delicious delicious delicious";
            item.soldout = [NSNumber numberWithBool:NO];
            [array addObject:item];
        }
    }
    
    return [array JSONData];
}

- (NSData *)dishItemDataOfTestingUpdateAndAdd
{
    NSArray *names = kSFDishClassName;
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:20];
    
    int count = 8 + arc4random() % 6;
    for (int j = 0; j < count; j++)
    {
        SFDishItem *item = [[SFDishItem alloc] init];
        item.itemid = [NSNumber numberWithInteger:1000 + j];
        item.classid = [NSNumber numberWithInteger:10];
        item.vip = [NSNumber numberWithBool:TRUE];
        item.name = [NSString stringWithFormat:@"会员专属_%d", j];
        item.englishName = [NSString stringWithFormat:@"VIP_%d", j];
        item.imageKey = [NSString stringWithFormat:@"1-%d@%.0f", j, [[NSDate date] timeIntervalSince1970]];
        item.thumbnailKey = [NSString stringWithFormat:@"2-%d@%.0f", j, [[NSDate date] timeIntervalSince1970]];
        item.showSequence = [NSNumber numberWithInteger:j + 1];
        item.price = [NSNumber numberWithFloat:20 + arc4random() % 100];
        item.favor = [NSNumber numberWithInteger:1000 + arc4random() % 5000];
        item.ingredient = @"此物只应天上有，人间能够几回尝，此时不尝何时尝？原料顶级棒，安全放心，注意注意，前方高能预警，核能预警！巨美味巨好吃，嘿咻嘿咻北鼻够~\nVery delicious delicious delicious";
        item.soldout = [NSNumber numberWithBool:NO];
        [array addObject:item];
    }
    
    for (int i = 0; i < [names count]; i++)
    {
        SFDishItem *update = [[SFDishItem alloc] init];
        update.itemid = [NSNumber numberWithInteger:i * 100];
        update.classid = [NSNumber numberWithInteger:i];
        update.soldout = [NSNumber numberWithBool:YES];
        [array addObject:update];
    }
    
    return [array JSONData];
}

- (void)tableDataOfTesting
{
    self.tables = @[
                    @{
                        @"name": @"A1",
                        @"id": @1
                        },
                    @{
                        @"name": @"A2",
                        @"id": @2
                        },
                    @{
                        @"name": @"B1",
                        @"id": @3
                        },
                    @{
                        @"name": @"B2",
                        @"id": @4
                        },
                    @{
                        @"name": @"C1",
                        @"id": @5
                        },
                    @{
                        @"name": @"C2",
                        @"id": @6
                        }
                    ];
}

#endif

@end
