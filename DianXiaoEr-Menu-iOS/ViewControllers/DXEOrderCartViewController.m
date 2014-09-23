//
//  DXEOrderCartViewController.m
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 9/17/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "DXEOrderCartViewController.h"
#import "DXEDishItem.h"
#import "DXEOrderManager.h"
#import "DXEOrderDishTableViewCell.h"
#import "DXEOrderTitleView.h"
#import "DXEEnsureOrderingView.h"

@interface DXEOrderCartViewController ()

@property (nonatomic, strong) DXEOrderTitleView *titleView;
@property (nonatomic, strong) DXEEnsureOrderingView *ensureOrderingView;
@property (nonatomic, assign) float totalPrice;

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
    
    self.view.backgroundColor = [[RNThemeManager sharedManager] colorForKey:@"BackgroundColor"];
    
    [self.dishesTableView registerNib:[UINib nibWithNibName:@"DXEOrderDishTableViewCell" bundle:nil]
               forCellReuseIdentifier:@"DXEOrderDishTableViewCell"];
    
    self.titleView = [[[NSBundle mainBundle] loadNibNamed:@"DXEOrderTitleView"
                                                    owner:self
                                                  options:nil] firstObject];
    self.titleView.nameTitle.text = @"已点菜品";
    
    self.ensureOrderingView = [[[NSBundle mainBundle] loadNibNamed:@"DXEEnsureOrderingView"
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
    for (DXEDishItem *item in [DXEOrderManager sharedInstance].cart)
    {
        totalPrice += [item.price floatValue] * [item.count integerValue];
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
    DXEOrderDishTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DXEOrderDishTableViewCell" forIndexPath:indexPath];
    DXEDishItem *item = [[DXEOrderManager sharedInstance].cart objectAtIndex:indexPath.row];
    
    cell.controller = self;
    cell.dishName.text = item.name;
    cell.dishEnglishName.text = item.englishName;
    cell.dishPrice.text = [NSString stringWithFormat:@"单价：￥%.2f", [item.price floatValue]];
    [cell updateCellByDishCount:[item.count integerValue] dishPrice:[item.price floatValue]];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return self.titleView;
    }

    return nil;
}

#pragma mark - target-action

- (void)onIncreaseButtonClickedInTableCell:(DXEOrderDishTableViewCell *)cell
{
    NSIndexPath *indexPath = [self.dishesTableView indexPathForCell:cell];
    DXEDishItem *item = [[DXEOrderManager sharedInstance].cart objectAtIndex:indexPath.row];
    if ([item.count integerValue] < kDXEDishItemCountInCartMax)
    {
        item.count = [NSNumber numberWithInteger:[item.count integerValue] + 1];
        self.totalPrice += [item.price floatValue];
    }
    [cell updateCellByDishCount:[item.count integerValue] dishPrice:[item.price floatValue]];
}

- (void)onDecreaseButtonClickedInTableCell:(DXEOrderDishTableViewCell *)cell
{
    NSIndexPath *indexPath = [self.dishesTableView indexPathForCell:cell];
    DXEDishItem *item = [[DXEOrderManager sharedInstance].cart objectAtIndex:indexPath.row];
    if ([item.count integerValue] > kDXEDishItemCountInCartMin)
    {
        item.count = [NSNumber numberWithInteger:[item.count integerValue] - 1];
        self.totalPrice -= [item.price floatValue];
    }
    [cell updateCellByDishCount:[item.count integerValue] dishPrice:[item.price floatValue]];
}

- (void)onDeleteButtonClickedInTableCell:(DXEOrderDishTableViewCell *)cell
{
    NSIndexPath *indexPath = [self.dishesTableView indexPathForCell:cell];
    DXEDishItem *item = [[DXEOrderManager sharedInstance].cart objectAtIndex:indexPath.row];
    self.totalPrice -= [item.price floatValue] * [item.count integerValue];
    [[DXEOrderManager sharedInstance].cart removeObjectIdenticalTo:item];
    [self.dishesTableView deleteRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:UITableViewRowAnimationFade];
}

- (IBAction)onEnsureOrderingButtonClicked:(id)sender
{
    NSLog(@"ensure ordering, total price is %0.2f", self.totalPrice);
    
    for (DXEDishItem *item in [DXEOrderManager sharedInstance].cart)
    {
        DXEDishItem *orderedItem = [item copy];
        [[DXEOrderManager sharedInstance].todo addObject:orderedItem];
    }
    [[DXEOrderManager sharedInstance].cart removeAllObjects];
    self.totalPrice = 0.0;
    [self.dishesTableView reloadData];
}

@end
