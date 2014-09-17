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

@interface DXEOrderCartViewController ()

@end

@implementation DXEOrderCartViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.titleView.layer.cornerRadius = 5;
    self.titleView.layer.borderWidth = 1;
    self.titleView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    [self.dishesTableView registerNib:[UINib nibWithNibName:@"DXEDishInCartTableViewCell" bundle:nil]
         forCellReuseIdentifier:@"DXEDishInCartTableViewCell"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.dishesTableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[DXEOrderManager sharedInstance].cartList count];
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DXEDishInCartTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DXEDishInCartTableViewCell" forIndexPath:indexPath];
    DXEDishItem *item = [[NSArray arrayWithArray:[DXEOrderManager sharedInstance].cartList] objectAtIndex:indexPath.row];
    
    cell.controller = self;
    cell.dishName.text = item.name;
    cell.dishEnglishName.text = item.englishName;
    cell.dishPrice.text = [NSString stringWithFormat:@"￥%.2f", [item.price floatValue]];
    [cell updateDishCountButtonsByCount:item.count];
    
    return cell;
}

#pragma mark - target-action

- (void)onIncreaseButtonClickedInTableCell:(DXEDishInCartTableViewCell *)cell
{
    NSIndexPath *indexPath = [self.dishesTableView indexPathForCell:cell];
    DXEDishItem *item = [[DXEOrderManager sharedInstance].cartList objectAtIndex:indexPath.row];
    if (item.count < kDXEDishItemCountInCartMax)
    {
        item.count++;
    }
    [cell updateDishCountButtonsByCount:item.count];
}

- (void)onDecreaseButtonClickedInTableCell:(DXEDishInCartTableViewCell *)cell
{
    NSIndexPath *indexPath = [self.dishesTableView indexPathForCell:cell];
    DXEDishItem *item = [[DXEOrderManager sharedInstance].cartList objectAtIndex:indexPath.row];
    if (item.count > kDXEDishItemCountInCartMin)
    {
        item.count--;
    }
    [cell updateDishCountButtonsByCount:item.count];
}

- (void)onDeleteButtonClickedInTableCell:(DXEDishInCartTableViewCell *)cell
{
    NSIndexPath *indexPath = [self.dishesTableView indexPathForCell:cell];
    DXEDishItem *item = [[DXEOrderManager sharedInstance].cartList objectAtIndex:indexPath.row];
    item.inCart = NO;
    item.count = 0;
    [[DXEOrderManager sharedInstance].cartList removeObjectIdenticalTo:item];
    [self.dishesTableView deleteRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:UITableViewRowAnimationFade];
}

@end
