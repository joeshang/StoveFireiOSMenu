//
//  DXEOrderStatusViewController.m
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 9/24/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "DXEOrderProgressViewController.h"
#import "DXEOrderProgressTableViewCell.h"
#import "DXEOrderProgressTitleView.h"
#import "DXEOrderManager.h"
#import "DXEImageManager.h"
#import "DXEDishItem.h"
#import "AFNetworking.h"

#define kDXEOrderProgressUpdatingInterval       15.0

@interface DXEOrderProgressViewController () < NSXMLParserDelegate >

@property (nonatomic, strong) NSTimer *progressTimer;
@property (nonatomic, strong) AFHTTPSessionManager *httpManager;
@property (nonatomic, strong) NSString *responseContent;

@end

#pragma mark - init & dealloc

@implementation DXEOrderProgressViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [[DXEOrderManager sharedInstance] addObserver:self
                                           forKeyPath:NSStringFromSelector(@selector(orderList))
                                              options:NSKeyValueObservingOptionNew
                                              context:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onUpdateOrderProgressNotification:)
                                                     name:kDXEDidUpdateOrderProgressNotification
                                                   object:nil];
        
        NSURL *baseURL = [NSURL URLWithString:kDXEWebServiceBaseURL];
        _httpManager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
        _httpManager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    }
    return self;
}

- (void)dealloc
{
    [_progressTimer invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[DXEOrderManager sharedInstance] removeObserver:self
                                          forKeyPath:NSStringFromSelector(@selector(orderList))];
}

#pragma mark - view related

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIColor *backgroundColor = [[RNThemeManager sharedManager] colorForKey:@"BackgroundColor"];
    self.view.backgroundColor = backgroundColor;
    
    [self updateProgressCounts];
    
    NSString *nibName = NSStringFromClass([DXEOrderProgressTableViewCell class]);
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
    float totalPrice = 0.0;
    
    for (DXEDishItem *item in [DXEOrderManager sharedInstance].order)
    {
        switch ([item.progress integerValue])
        {
            case DXEDishProgressTodo:
                todoCount += [item.count intValue];
                break;
            case DXEDishProgressDoing:
                doingCount += [item.count intValue];
                break;
            case DXEDishProgressDone:
                doneCount += [item.count intValue];
                break;
            default:
                break;
        }
        
        totalPrice += [item.price floatValue] * [item.count integerValue];
    }
    
    self.todoCount.text = [NSString stringWithFormat:@"%d", todoCount];
    self.doingCount.text = [NSString stringWithFormat:@"%d", doingCount];
    self.doneCount.text = [NSString stringWithFormat:@"%d", doneCount];
    self.totalPrice.text = [NSString stringWithFormat:@"%.2f元", totalPrice];
    
    if (doneCount == [[DXEOrderManager sharedInstance].order count])
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
    return [[DXEOrderManager sharedInstance].order count];
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DXEDishItem *item = [[DXEOrderManager sharedInstance].order objectAtIndex:indexPath.row];
    
    NSString *identifier = NSStringFromClass([DXEOrderProgressTableViewCell class]);
    DXEOrderProgressTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    cell.dishName.text = item.name;
    cell.dishEnglishName.text = item.englishName;
    cell.dishCount.text = [item.count stringValue];
    cell.dishPrice.text = [NSString stringWithFormat:@"单价：￥%.2f", [item.price floatValue]];
    cell.dishTotalPrice.text = [NSString stringWithFormat:@"￥%.2f", [item.price floatValue] * [item.count integerValue]];
    cell.dishThumbnail.image = [[DXEImageManager sharedInstance] imageForKey:item.thumbnailKey];
    cell.state = [item.progress integerValue];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    NSString *nibName = NSStringFromClass([DXEOrderProgressTitleView class]);
    DXEOrderProgressTitleView *titleView = [[[NSBundle mainBundle] loadNibNamed:nibName
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
            self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:kDXEOrderProgressUpdatingInterval
                                                                  target:self
                                                                selector:@selector(onProgressTimer:)
                                                                userInfo:nil
                                                                 repeats:YES];
        }
    }
}

- (void)onProgressTimer:(NSTimer *)timer
{
    NSMutableArray *request = [NSMutableArray arrayWithCapacity:[[DXEOrderManager sharedInstance].order count]];
    for (DXEDishItem *item in [DXEOrderManager sharedInstance].order)
    {
        if (item.tradeid)
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
        DXEDishItem *item = [[[DXEOrderManager sharedInstance].order filteredArrayUsingPredicate:predicate] firstObject];
        item.progress = [dict objectForKey:@"status"];
    }
    
    [self updateProgressCounts];
    [self.dishesTableView reloadData];
}

@end
