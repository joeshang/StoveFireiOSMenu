//
//  SFOrderStatusViewController.m
//  StoveFireiOSMenu
//
//  Created by Joe Shang on 9/24/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "SFOrderProgressViewController.h"
#import "SFOrderProgressTableViewCell.h"
#import "SFOrderProgressTitleView.h"
#import "SFDishItem.h"
#import "SFOrderItem.h"
#import "SFDataManager.h"
#import "SFOrderManager.h"
#import "SFImageManager.h"
#import "AFNetworking.h"

#define kSFOrderProgressUpdatingInterval       15.0

@interface SFOrderProgressViewController () < NSXMLParserDelegate >

@property (nonatomic, strong) NSTimer *progressTimer;
@property (nonatomic, strong) AFHTTPSessionManager *httpManager;
@property (nonatomic, strong) NSString *responseContent;

@end

#pragma mark - init & dealloc

@implementation SFOrderProgressViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [[SFOrderManager sharedInstance] addObserver:self
                                           forKeyPath:NSStringFromSelector(@selector(orderList))
                                              options:NSKeyValueObservingOptionNew
                                              context:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onUpdateOrderProgressNotification:)
                                                     name:kSFDidUpdateOrderProgressNotification
                                                   object:nil];
        
        NSURL *baseURL = [NSURL URLWithString:kSFWebServiceBaseURL];
        _httpManager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
        _httpManager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    }
    return self;
}

- (void)dealloc
{
    [_progressTimer invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[SFOrderManager sharedInstance] removeObserver:self
                                          forKeyPath:NSStringFromSelector(@selector(orderList))];
}

#pragma mark - view related

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIColor *backgroundColor = [[RNThemeManager sharedManager] colorForKey:@"BackgroundColor"];
    self.view.backgroundColor = backgroundColor;
    
    [self updateProgressCounts];
    
    NSString *nibName = NSStringFromClass([SFOrderProgressTableViewCell class]);
    [self.dishesTableView registerNib:[UINib nibWithNibName:nibName bundle:nil]
               forCellReuseIdentifier:nibName];
    self.dishesTableView.backgroundColor = backgroundColor;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)updateProgressCounts
{
    int todoCount = 0;
    int doingCount = 0;
    int doneCount = 0;
    int totalCount = 0;
    float totalPrice = 0.0;
    
    for (SFOrderItem *item in [SFOrderManager sharedInstance].order)
    {
        switch ([item.progress integerValue])
        {
            case SFDishProgressTodo:
                todoCount += [item.count intValue];
                break;
            case SFDishProgressDoing:
                doingCount += [item.count intValue];
                break;
            case SFDishProgressDone:
                doneCount += [item.count intValue];
                break;
            default:
                break;
        }
        
        SFDishItem *dish = [[SFDataManager sharedInstance].dishes objectForKey:item.itemid];
        totalPrice += [dish.price floatValue] * [item.count integerValue];
        totalCount += [item.count integerValue];
    }
    
    self.todoCount.text = [NSString stringWithFormat:@"%d", todoCount];
    self.doingCount.text = [NSString stringWithFormat:@"%d", doingCount];
    self.doneCount.text = [NSString stringWithFormat:@"%d", doneCount];
    self.totalPrice.text = [NSString stringWithFormat:@"%.2f元", totalPrice];
    
    if (doneCount == totalCount)
    {
        [self.progressTimer invalidate];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[SFOrderManager sharedInstance].order count];
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SFOrderItem *item = [[SFOrderManager sharedInstance].order objectAtIndex:indexPath.row];
    SFDishItem *dish = [[SFDataManager sharedInstance].dishes objectForKey:item.itemid];
    
    NSString *identifier = NSStringFromClass([SFOrderProgressTableViewCell class]);
    SFOrderProgressTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    cell.dishName.text = dish.name;
    cell.dishEnglishName.text = dish.englishName;
    cell.dishCount.text = [item.count stringValue];
    cell.dishPrice.text = [NSString stringWithFormat:@"单价：￥%.2f", [dish.price floatValue]];
    cell.dishTotalPrice.text = [NSString stringWithFormat:@"￥%.2f", [dish.price floatValue] * [item.count integerValue]];
    UIImage *thumbnail = [[SFImageManager sharedInstance] imageForKey:dish.thumbnailKey];
    if (!thumbnail)
    {
        thumbnail = [UIImage imageNamed:@"default_dish_thumbnail"];
    }
    cell.dishThumbnail.image = thumbnail;
    cell.state = [item.progress integerValue];
    if ([dish.vip boolValue])
    {
        cell.dishVipFlag.hidden = NO;
    }
    else
    {
        cell.dishVipFlag.hidden = YES;
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    NSString *nibName = NSStringFromClass([SFOrderProgressTitleView class]);
    SFOrderProgressTitleView *titleView = [[[NSBundle mainBundle] loadNibNamed:nibName
                                                                      owner:self
                                                                    options:nil] firstObject];
    return titleView;
}

#pragma mark - notification

- (void)onUpdateOrderProgressNotification:(NSNotification *)notification
{
    [self updateProgressCounts];
    [self.dishesTableView reloadData];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(orderList))])
    {
        [self updateProgressCounts];
        [self.dishesTableView reloadData];
        
        if (self.progressTimer == nil || self.progressTimer.valid == NO)
        {
            self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:kSFOrderProgressUpdatingInterval
                                                                  target:self
                                                                selector:@selector(onProgressTimer:)
                                                                userInfo:nil
                                                                 repeats:YES];
        }
    }
}

- (void)onProgressTimer:(NSTimer *)timer
{
#ifdef SF_UI_TEST
    for (SFOrderItem *item in [SFOrderManager sharedInstance].order)
    {
        int progress = [item.progress intValue];
        if (progress != SFDishProgressDone)
        {
            progress++;
            item.progress = [NSNumber numberWithInt:progress];
            return;
        }
    }
#else
    NSMutableArray *request = [NSMutableArray arrayWithCapacity:[[SFOrderManager sharedInstance].order count]];
    for (SFOrderItem *item in [SFOrderManager sharedInstance].order)
    {
        if ([item.tradeid intValue] != -1)
        {
            [request addObject:item.tradeid];
        }
    }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:request options:NSJSONWritingPrettyPrinted error:nil];
    NSDictionary *parameters = @{
                                 @"idList": [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]
                                 };
    
    [self.httpManager POST:@"GetOrderStatus" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject){
        NSXMLParser *parser = (NSXMLParser *)responseObject;
        parser.delegate = self;
        [parser parse];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@", error);
    }];
#endif
}

#pragma mark - NSXMLParser

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    self.responseContent = [NSString string];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    self.responseContent = [self.responseContent stringByAppendingString:string];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    NSArray *progress = [NSJSONSerialization JSONObjectWithData:[self.responseContent dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    for (NSDictionary *dict in progress)
    {
        int tradeid = [[dict objectForKey:@"trade_id"] intValue];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tradeid == %d", tradeid];
        SFOrderItem *item = [[[SFOrderManager sharedInstance].order filteredArrayUsingPredicate:predicate] firstObject];
        if ([[dict objectForKey:@"status"] intValue] == -1)
        {
            [[SFOrderManager sharedInstance].order removeObjectIdenticalTo:item];
            if ([[SFOrderManager sharedInstance].order count] == 0)
            {
                [self.progressTimer invalidate];
            }
        }
        else
        {
            item.progress = [dict objectForKey:@"status"];
        }
    }
}

@end
