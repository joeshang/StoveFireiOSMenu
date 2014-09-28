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
#import "DXEDishItem.h"

@interface DXEOrderProgressViewController ()

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
                                                 selector:@selector(onOrderProgressUpdating:)
                                                     name:@"OrderProgressUpdating"
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
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

- (void)onOrderProgressUpdating:(NSNotification *)notification
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
    }
}

@end
