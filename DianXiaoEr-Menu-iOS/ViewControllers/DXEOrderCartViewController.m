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
#import "DXEDishInCartTableViewCell.h"
#import "DXEEnsureOrderingView.h"

@interface DXEOrderCartViewController ()

@property (nonatomic, strong) DXEEnsureOrderingView *ensureOrderingView;
@property (nonatomic, assign) float totalPrice;

@end

@implementation DXEOrderCartViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _totalPrice = 0.0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.titleView.layer.cornerRadius = kDXEOrderTitleViewRadius;
    self.titleView.layer.borderWidth = kDXEOrderTitleViewBorderWidth;
    self.titleView.layer.borderColor = [[[RNThemeManager sharedManager] colorForKey:@"Order.TitleView.BorderColor"] CGColor];;
    
    [self.dishesTableView registerNib:[UINib nibWithNibName:@"DXEDishInCartTableViewCell" bundle:nil]
         forCellReuseIdentifier:@"DXEDishInCartTableViewCell"];
    
    self.ensureOrderingView = [[[NSBundle mainBundle] loadNibNamed:@"DXEEnsureOrderingView"
                                                            owner:self
                                                           options:nil] firstObject];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.dishesTableView reloadData];
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
    DXEDishInCartTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DXEDishInCartTableViewCell" forIndexPath:indexPath];
    DXEDishItem *item = [[NSArray arrayWithArray:[DXEOrderManager sharedInstance].cart] objectAtIndex:indexPath.row];
    
    cell.controller = self;
    cell.dishName.text = item.name;
    cell.dishEnglishName.text = item.englishName;
    cell.dishPrice.text = [NSString stringWithFormat:@"￥%.2f", [item.price floatValue]];
    [cell updateDishCountButtonsByCount:item.count];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    float total = 0.0;
    for (DXEDishItem *item in [DXEOrderManager sharedInstance].cart)
    {
        float price = [item.price floatValue];
        total += price * item.count;
    }
    self.totalPrice = total;
    
    return self.ensureOrderingView;
}

#pragma mark - target-action

- (void)onIncreaseButtonClickedInTableCell:(DXEDishInCartTableViewCell *)cell
{
    NSIndexPath *indexPath = [self.dishesTableView indexPathForCell:cell];
    DXEDishItem *item = [[DXEOrderManager sharedInstance].cart objectAtIndex:indexPath.row];
    if (item.count < kDXEDishItemCountInCartMax)
    {
        item.count++;
        self.totalPrice += [item.price floatValue];
    }
    [cell updateDishCountButtonsByCount:item.count];
}

- (void)onDecreaseButtonClickedInTableCell:(DXEDishInCartTableViewCell *)cell
{
    NSIndexPath *indexPath = [self.dishesTableView indexPathForCell:cell];
    DXEDishItem *item = [[DXEOrderManager sharedInstance].cart objectAtIndex:indexPath.row];
    if (item.count > kDXEDishItemCountInCartMin)
    {
        item.count--;
        self.totalPrice -= [item.price floatValue];
    }
    [cell updateDishCountButtonsByCount:item.count];
}

- (void)onDeleteButtonClickedInTableCell:(DXEDishInCartTableViewCell *)cell
{
    NSIndexPath *indexPath = [self.dishesTableView indexPathForCell:cell];
    DXEDishItem *item = [[DXEOrderManager sharedInstance].cart objectAtIndex:indexPath.row];
    self.totalPrice -= [item.price floatValue] * item.count;
    item.inCart = NO;
    item.count = 0;
    [[DXEOrderManager sharedInstance].cart removeObjectIdenticalTo:item];
    [self.dishesTableView deleteRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:UITableViewRowAnimationFade];
}

- (IBAction)onEnsureOrderingButtonClicked:(id)sender
{
    NSLog(@"ensure ordering, total price is %0.2f", self.totalPrice);
}

@end
