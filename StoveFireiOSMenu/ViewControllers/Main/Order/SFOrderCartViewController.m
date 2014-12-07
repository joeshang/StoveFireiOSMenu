//
//  SFOrderCartViewController.m
//  StoveFireiOSMenu
//
//  Created by Joe Shang on 9/17/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "SFOrderCartViewController.h"
#import "SFDishItem.h"
#import "SFOrderItem.h"
#import "SFDataManager.h"
#import "SFImageManager.h"
#import "SFOrderManager.h"
#import "SFOrderCartTableViewCell.h"
#import "SFOrderCartTitleView.h"
#import "SFEnsureOrderingView.h"
#import "AFNetworking.h"
#import "SVProgressHUD.h"

@interface SFOrderCartViewController () < NSXMLParserDelegate >

@property (nonatomic, strong) SFEnsureOrderingView *ensureOrderingView;
@property (nonatomic, assign) float totalPrice;
@property (nonatomic, strong) NSString *responseContent;

@end

@implementation SFOrderCartViewController

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
    
    NSString *nibName = NSStringFromClass([SFOrderCartTableViewCell class]);
    [self.dishesTableView registerNib:[UINib nibWithNibName:nibName bundle:nil]
               forCellReuseIdentifier:nibName];
    self.dishesTableView.backgroundColor = backgroundColor;
    
    nibName = NSStringFromClass([SFEnsureOrderingView class]);
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
    for (SFOrderItem *item in [SFOrderManager sharedInstance].cart)
    {
        SFDishItem *dish = [[SFDataManager sharedInstance].dishes objectForKey:item.itemid];
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
    return [[SFOrderManager sharedInstance].cart count];
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SFOrderItem *item = [[SFOrderManager sharedInstance].cart objectAtIndex:indexPath.row];
    SFDishItem *dish = [[SFDataManager sharedInstance].dishes objectForKey:item.itemid];
    
    NSString *identifier = NSStringFromClass([SFOrderCartTableViewCell class]);
    SFOrderCartTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    cell.controller = self;
    cell.dishName.text = dish.name;
    cell.dishEnglishName.text = dish.englishName;
    cell.dishPrice.text = [NSString stringWithFormat:@"单价：￥%.2f", [dish.price floatValue]];
    UIImage *thumbnail = [[SFImageManager sharedInstance] imageForKey:dish.thumbnailKey];
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
    NSString *nibName = NSStringFromClass([SFOrderCartTitleView class]);
    SFOrderCartTitleView *titleView = [[[NSBundle mainBundle] loadNibNamed:nibName
                                                                      owner:self
                                                                    options:nil] firstObject];
    return titleView;
}

#pragma mark - target-action

- (void)onIncreaseButtonClickedInTableCell:(SFOrderCartTableViewCell *)cell
{
    NSIndexPath *indexPath = [self.dishesTableView indexPathForCell:cell];
    SFOrderItem *item = [[SFOrderManager sharedInstance].cart objectAtIndex:indexPath.row];
    SFDishItem *dish = [[SFDataManager sharedInstance].dishes objectForKey:item.itemid];
    if ([item.count integerValue] < kSFDishItemCountInCartMax)
    {
        item.count = [NSNumber numberWithInteger:[item.count integerValue] + 1];
        self.totalPrice += [dish.price floatValue];
    }
    [cell updateCellByDishCount:[item.count integerValue] dishPrice:[dish.price floatValue]];
}

- (void)onDecreaseButtonClickedInTableCell:(SFOrderCartTableViewCell *)cell
{
    NSIndexPath *indexPath = [self.dishesTableView indexPathForCell:cell];
    SFOrderItem *item = [[SFOrderManager sharedInstance].cart objectAtIndex:indexPath.row];
    SFDishItem *dish = [[SFDataManager sharedInstance].dishes objectForKey:item.itemid];
    if ([item.count integerValue] > kSFDishItemCountInCartMin)
    {
        item.count = [NSNumber numberWithInteger:[item.count integerValue] - 1];
        self.totalPrice -= [dish.price floatValue];
    }
    [cell updateCellByDishCount:[item.count integerValue] dishPrice:[dish.price floatValue]];
}

- (void)onDeleteButtonClickedInTableCell:(SFOrderCartTableViewCell *)cell
{
    NSIndexPath *indexPath = [self.dishesTableView indexPathForCell:cell];
    SFOrderItem *item = [[SFOrderManager sharedInstance].cart objectAtIndex:indexPath.row];
    SFDishItem *dish = [[SFDataManager sharedInstance].dishes objectForKey:item.itemid];
    self.totalPrice -= [dish.price floatValue] * [item.count integerValue];
    [[SFOrderManager sharedInstance].cart removeObjectIdenticalTo:item];
    [self.dishesTableView deleteRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:UITableViewRowAnimationFade];
}

- (void)updateDataAfterOrdering
{
    NSRange range;
    range.location = 0;
    range.length = [[SFOrderManager sharedInstance].cart count];
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
    [[SFOrderManager sharedInstance].order insertObjects:[SFOrderManager sharedInstance].cart
                                               atIndexes:indexSet];
    [[SFOrderManager sharedInstance].cart removeAllObjects];
    self.totalPrice = 0.0;
    [self.dishesTableView reloadData];
}

- (IBAction)onEnsureOrderingButtonClicked:(id)sender
{
#ifdef SF_UI_TEST
    [self updateDataAfterOrdering];
#else
    NSMutableArray *orderList = [NSMutableArray arrayWithCapacity:[[SFOrderManager sharedInstance].cart count]];
    for (SFOrderItem *item in [SFOrderManager sharedInstance].cart)
    {
        NSDictionary *orderedItem  = @{
                               @"open_id": [SFDataManager sharedInstance].openid,
                               @"table_id": [SFDataManager sharedInstance].tableid,
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
    
    NSURL *baseURL = [NSURL URLWithString:kSFWebServiceBaseURL];
    AFHTTPSessionManager *httpManager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    httpManager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    [httpManager POST:@"PlaceOrder" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject){
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
    if ([self.responseContent isEqualToString:@""])
    {
        [SVProgressHUD showErrorWithStatus:@"当前桌号不匹配,下单失败"];
    }
    else
    {
        [SVProgressHUD dismiss];
        
        NSString *soldoutDishesName = @"";
        NSArray *orderResults = [NSJSONSerialization JSONObjectWithData:[self.responseContent dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
        for (NSDictionary *result in orderResults)
        {
            int itemid = [[result objectForKey:@"dish_id"] intValue];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemid == %d", itemid];
            SFOrderItem *item = [[[SFOrderManager sharedInstance].cart filteredArrayUsingPredicate:predicate] firstObject];
            item.tradeid = [result objectForKey:@"trade_id"];
            
            // 处理菜品售罄的情况
            if ([item.tradeid integerValue] == -1)
            {
                SFDishItem *dishItem = [[SFDataManager sharedInstance].dishes objectForKey:item.itemid];
                dishItem.soldout = [NSNumber numberWithBool:YES];
                soldoutDishesName = [soldoutDishesName stringByAppendingString:[NSString stringWithFormat:@" “%@” ", dishItem.name]];
                [[SFOrderManager sharedInstance].cart removeObject:item];
            }
        }
        
        [self updateDataAfterOrdering];
        
        if (![soldoutDishesName isEqualToString:@""])
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"很抱歉的通知您"
                                                                message:[NSString stringWithFormat:@"%@已售罄，请您挑选其他菜品", soldoutDishesName]
                                                               delegate:nil
                                                      cancelButtonTitle:@"确定"
                                                      otherButtonTitles:nil, nil];
            [alertView show];
        }
    }
}

@end
