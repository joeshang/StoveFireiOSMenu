//
//  DXEOrderCartViewController.m
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 9/17/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "DXEOrderCartViewController.h"
#import "DXEDishItem.h"
#import "DXEOrderItem.h"
#import "DXEDataManager.h"
#import "DXEImageManager.h"
#import "DXEOrderManager.h"
#import "DXEOrderCartTableViewCell.h"
#import "DXEOrderCartTitleView.h"
#import "DXEEnsureOrderingView.h"
#import "AFNetworking.h"
#import "SVProgressHUD.h"

@interface DXEOrderCartViewController () < NSXMLParserDelegate >

@property (nonatomic, strong) DXEEnsureOrderingView *ensureOrderingView;
@property (nonatomic, assign) float totalPrice;
@property (nonatomic, strong) NSString *responseContent;

@end

@implementation DXEOrderCartViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _totalPrice = 0.0;
    }
    return self;
}

#pragma mark - view related

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIColor *backgroundColor = [[RNThemeManager sharedManager] colorForKey:@"BackgroundColor"];
    self.view.backgroundColor = backgroundColor;
    
    NSString *nibName = NSStringFromClass([DXEOrderCartTableViewCell class]);
    [self.dishesTableView registerNib:[UINib nibWithNibName:nibName bundle:nil]
               forCellReuseIdentifier:nibName];
    self.dishesTableView.backgroundColor = backgroundColor;
    
    nibName = NSStringFromClass([DXEEnsureOrderingView class]);
    self.ensureOrderingView = [[[NSBundle mainBundle] loadNibNamed:nibName
                                                             owner:self
                                                           options:nil] firstObject];
    self.dishesTableView.tableFooterView = self.ensureOrderingView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.dishesTableView reloadData];
    float totalPrice = 0.0;
    for (DXEOrderItem *item in [DXEOrderManager sharedInstance].cart)
    {
        DXEDishItem *dish = [[DXEDataManager sharedInstance].dishes objectForKey:item.itemid];
        totalPrice += [dish.price floatValue] * [item.count integerValue];
    }
    self.totalPrice = totalPrice;
}

- (void)setTotalPrice:(float)totalPrice
{
    _totalPrice = totalPrice;
    self.ensureOrderingView.totalPrice.text = [NSString stringWithFormat:@"￥%.2f", _totalPrice];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[DXEOrderManager sharedInstance].cart count];
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DXEOrderItem *item = [[DXEOrderManager sharedInstance].cart objectAtIndex:indexPath.row];
    DXEDishItem *dish = [[DXEDataManager sharedInstance].dishes objectForKey:item.itemid];
    
    NSString *identifier = NSStringFromClass([DXEOrderCartTableViewCell class]);
    DXEOrderCartTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    cell.controller = self;
    cell.dishName.text = dish.name;
    cell.dishEnglishName.text = dish.englishName;
    cell.dishPrice.text = [NSString stringWithFormat:@"单价：￥%.2f", [dish.price floatValue]];
    UIImage *thumbnail = [[DXEImageManager sharedInstance] imageForKey:dish.thumbnailKey];
    if (!thumbnail)
    {
        thumbnail = [UIImage imageNamed:@"default_dish_thumbnail"];
    }
    cell.dishThumbnail.image = thumbnail;
    [cell updateCellByDishCount:[item.count integerValue] dishPrice:[dish.price floatValue]];
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
    NSString *nibName = NSStringFromClass([DXEOrderCartTitleView class]);
    DXEOrderCartTitleView *titleView = [[[NSBundle mainBundle] loadNibNamed:nibName
                                                                      owner:self
                                                                    options:nil] firstObject];
    return titleView;
}

#pragma mark - target-action

- (void)onIncreaseButtonClickedInTableCell:(DXEOrderCartTableViewCell *)cell
{
    NSIndexPath *indexPath = [self.dishesTableView indexPathForCell:cell];
    DXEOrderItem *item = [[DXEOrderManager sharedInstance].cart objectAtIndex:indexPath.row];
    DXEDishItem *dish = [[DXEDataManager sharedInstance].dishes objectForKey:item.itemid];
    if ([item.count integerValue] < kDXEDishItemCountInCartMax)
    {
        item.count = [NSNumber numberWithInteger:[item.count integerValue] + 1];
        self.totalPrice += [dish.price floatValue];
    }
    [cell updateCellByDishCount:[item.count integerValue] dishPrice:[dish.price floatValue]];
}

- (void)onDecreaseButtonClickedInTableCell:(DXEOrderCartTableViewCell *)cell
{
    NSIndexPath *indexPath = [self.dishesTableView indexPathForCell:cell];
    DXEOrderItem *item = [[DXEOrderManager sharedInstance].cart objectAtIndex:indexPath.row];
    DXEDishItem *dish = [[DXEDataManager sharedInstance].dishes objectForKey:item.itemid];
    if ([item.count integerValue] > kDXEDishItemCountInCartMin)
    {
        item.count = [NSNumber numberWithInteger:[item.count integerValue] - 1];
        self.totalPrice -= [dish.price floatValue];
    }
    [cell updateCellByDishCount:[item.count integerValue] dishPrice:[dish.price floatValue]];
}

- (void)onDeleteButtonClickedInTableCell:(DXEOrderCartTableViewCell *)cell
{
    NSIndexPath *indexPath = [self.dishesTableView indexPathForCell:cell];
    DXEOrderItem *item = [[DXEOrderManager sharedInstance].cart objectAtIndex:indexPath.row];
    DXEDishItem *dish = [[DXEDataManager sharedInstance].dishes objectForKey:item.itemid];
    self.totalPrice -= [dish.price floatValue] * [item.count integerValue];
    [[DXEOrderManager sharedInstance].cart removeObjectIdenticalTo:item];
    [self.dishesTableView deleteRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:UITableViewRowAnimationFade];
}

- (void)updateDataAfterOrdering
{
    for (DXEOrderItem *item in [DXEOrderManager sharedInstance].cart)
    {
        [[DXEOrderManager sharedInstance].order addObject:item];
    }
    [[DXEOrderManager sharedInstance].cart removeAllObjects];
    self.totalPrice = 0.0;
    [self.dishesTableView reloadData];
}

- (IBAction)onEnsureOrderingButtonClicked:(id)sender
{
    NSLog(@"ensure ordering, total price is %0.2f", self.totalPrice);
    
#ifdef DXE_UI_TEST
    [self updateDataAfterOrdering];
#else
    NSMutableArray *orderList = [NSMutableArray arrayWithCapacity:[[DXEOrderManager sharedInstance].cart count]];
    for (DXEOrderItem *item in [DXEOrderManager sharedInstance].cart)
    {
        NSDictionary *orderedItem  = @{
                               @"open_id": [DXEDataManager sharedInstance].openid,
                               @"table_id": [DXEDataManager sharedInstance].tableid,
                               @"dish_id": item.itemid,
                               @"count": item.count
                               };
        [orderList addObject:orderedItem];
    }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:orderList options:NSJSONWritingPrettyPrinted error:nil];
    NSDictionary *parameters = @{
                                 @"order": [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]
                                 };
    
    [SVProgressHUD showWithStatus:@"下单中" maskType:SVProgressHUDMaskTypeClear];
    
    NSURL *baseURL = [NSURL URLWithString:kDXEWebServiceBaseURL];
    AFHTTPSessionManager *httpManager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    httpManager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    [httpManager POST:@"PlaceOrder" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject){
        [SVProgressHUD dismiss];
        
        NSXMLParser *parser = (NSXMLParser *)responseObject;
        parser.delegate = self;
        [parser parse];
    } failure:^(NSURLSessionDataTask *task, NSError *error){
        [SVProgressHUD showErrorWithStatus:@"网络错误,下单失败"];
        NSLog(@"%@", error);
    }];
#endif
}

#pragma mark - NSXMLParserDelegate 

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
    NSArray *orderResults = [NSJSONSerialization JSONObjectWithData:[self.responseContent dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    for (NSDictionary *result in orderResults)
    {
        int itemid = [[result objectForKey:@"dish_id"] intValue];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemid == %d", itemid];
        DXEOrderItem *item = [[[DXEOrderManager sharedInstance].cart filteredArrayUsingPredicate:predicate] firstObject];
        item.tradeid = [result objectForKey:@"trade_id"];
    }
    
    [self updateDataAfterOrdering];
}

@end
