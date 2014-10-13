//
//  DXEMyselfViewController.m
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 7/15/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "DXEMyselfViewController.h"
#import "DXEMember.h"
#import "DXEDishItem.h"
#import "DXERecordTableViewCell.h"
#import "DXEDiningRecord.h"
#import "DXERecordTitleView.h"
#import "DXERecordDetailView.h"
#import "DXERecordDetailFooterView.h"
#import "DXEOrderCartTableViewCell.h"
#import "DXEOrderCartTitleView.h"
#import "CRModal.h"

#define kDXERecordDetailCellWidth           594
#define kDXERecordDetailCellHeight          140
#define kDXERecordDetailExceptCellHeight    180
#define kDXERecordDetailMaxShowCount        4
#define kDXERecordDetailCountCenterX        352
#define kDXERecordDetailTotalPriceCenterX   497

@interface DXEMyselfViewController ()

@property (nonatomic, strong) DXEDiningRecord *detailedRecord;
@property (nonatomic, strong) DXERecordDetailView *recordDetailView;
@property (nonatomic, strong) DXERecordDetailFooterView *recordDetailFooterView;

@end

@implementation DXEMyselfViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _login = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIColor *backgroundColor = [[RNThemeManager sharedManager] colorForKey:@"BackgroundColor"];
    self.view.backgroundColor = backgroundColor;
    
    self.memberImage.clipsToBounds = YES;
    self.memberImage.layer.cornerRadius = self.memberImage.frame.size.width / 2;
    self.memberImage.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.memberImage.layer.borderWidth = 3;
    
    NSString *nibName = NSStringFromClass([DXERecordTableViewCell class]);
    [self.recordTableView registerNib:[UINib nibWithNibName:nibName bundle:nil]
               forCellReuseIdentifier:nibName];
    self.recordTableView.backgroundColor = backgroundColor;
    
    nibName = NSStringFromClass([DXERecordDetailView class]);
    self.recordDetailView = [[[NSBundle mainBundle] loadNibNamed:nibName
                                                           owner:self
                                                         options:nil] firstObject];
    nibName = NSStringFromClass([DXEOrderCartTableViewCell class]);
    [self.recordDetailView.dishesTableView registerNib:[UINib nibWithNibName:nibName bundle:nil] forCellReuseIdentifier:nibName];
    
    nibName = NSStringFromClass([DXERecordDetailFooterView class]);
    self.recordDetailFooterView = [[[NSBundle mainBundle] loadNibNamed:nibName
                                                                 owner:self
                                                               options:nil] firstObject];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.recordTableView)
    {
        return [self.member.records count];
    }
    else
    {
        return [self.detailedRecord.dishes count];
    }
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.recordTableView)
    {
        DXEDiningRecord *record = [self.member.records objectAtIndex:indexPath.row];
        
        NSString *identifier = NSStringFromClass([DXERecordTableViewCell class]);
        DXERecordTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        cell.controller = self;
        cell.date.text = record.date;
        cell.dishCount.text = [record.dishCount stringValue];
        cell.totalPrice.text = [NSString stringWithFormat:@"￥%.2f", [record.totalPrice floatValue]];
        
        return cell;
    }
    else
    {
        DXEDishItem *item = [self.detailedRecord.dishes objectAtIndex:indexPath.row];
        
        NSString *identifier = NSStringFromClass([DXEOrderCartTableViewCell class]);
        DXEOrderCartTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        cell.dishName.text = item.name;
        cell.dishEnglishName.text = item.englishName;
        cell.dishPrice.text = [NSString stringWithFormat:@"单价：￥%.2f", [item.price floatValue]];
        cell.dishTotalPrice.text = [NSString stringWithFormat:@"￥%.2f", [item.price floatValue] * [item.count integerValue]];
        cell.increaseButton.hidden = YES;
        cell.decreaseButton.hidden = YES;
        cell.countUnderline.hidden = YES;
        cell.deleteButton.hidden = YES;
        CGPoint center = cell.dishCount.center;
        center.x = kDXERecordDetailCountCenterX;
        cell.dishCount.center = center;
        center = cell.dishTotalPrice.center;
        center.x = kDXERecordDetailTotalPriceCenterX;
        cell.dishTotalPrice.center = center;
        cell.backgroundImageView.image = [[RNThemeManager sharedManager] imageForKey:@"myself_record_detail_cell_background.png"];
        CGRect frame = cell.frame;
        frame.size.width = kDXERecordDetailCellWidth;
        cell.frame = frame;
        
        return cell;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView == self.recordTableView)
    {
        NSString *nibName = NSStringFromClass([DXERecordTitleView class]);
        DXERecordTitleView *titleView = [[[NSBundle mainBundle] loadNibNamed:nibName
                                                                       owner:self
                                                                     options:nil] firstObject];
        return titleView;
    }
    else
    {
        NSString *nibName = NSStringFromClass([DXEOrderCartTitleView class]);
        DXEOrderCartTitleView *titleView = [[[NSBundle mainBundle] loadNibNamed:nibName
                                                                       owner:self
                                                                     options:nil] firstObject];
        titleView.nameTitle.text = @"菜品";
        CGRect frame = titleView.frame;
        frame.size.width = kDXERecordDetailCellWidth;
        titleView.frame = frame;
        CGPoint center = titleView.countTitle.center;
        center.x = kDXERecordDetailCountCenterX;
        titleView.countTitle.center = center;
        center = titleView.totalPriceTitle.center;
        center.x = kDXERecordDetailTotalPriceCenterX;
        titleView.totalPriceTitle.center = center;
        
        return titleView;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (tableView == self.recordTableView)
    {
        UIView *nullFooterView = [[UIView alloc] init];
        nullFooterView.backgroundColor = [UIColor clearColor];
        return nullFooterView;
    }
    else
    {
        return self.recordDetailFooterView;
    }
}

#pragma mark - setter

- (void)setMember:(DXEMember *)member
{
    _member = member;
    
    self.memberUppercaseName.text = [member.memberName uppercaseString];
    self.memberName.text = member.memberName;
    self.memberPhone.text = member.memberPhone;
    self.memberAccount.text = [NSString stringWithFormat:@"%@ 元", member.memberAccount];
    if ([member.records count] == 0)
    {
        self.recordEmptyTips.hidden = NO;
    }
    
    [self.recordTableView reloadData];
}

#pragma mark - notification

- (void)onDetailButtonClickedInTableCell:(DXERecordTableViewCell *)cell
{
    NSIndexPath *indexPath = [self.recordTableView indexPathForCell:cell];
    self.detailedRecord = [self.member.records objectAtIndex:indexPath.row];
    NSInteger showCount = kDXERecordDetailMaxShowCount;
    if ([self.detailedRecord.dishes count] < kDXERecordDetailMaxShowCount)
    {
        showCount = [self.detailedRecord.dishes count];
    }
    CGRect rect = self.recordDetailView.frame;
    rect.size.height = kDXERecordDetailExceptCellHeight + showCount * kDXERecordDetailCellHeight;
    self.recordDetailView.frame = rect;
    self.recordDetailFooterView.totalPrice.text = [NSString stringWithFormat:@"￥%.2f", [self.detailedRecord.totalPrice floatValue]];
    [self.recordDetailView.dishesTableView reloadData];

    [CRModal showModalView:self.recordDetailView
               coverOption:CRModalOptionCoverDark
       tapOutsideToDismiss:NO
                  animated:YES
                completion:nil];
}

- (IBAction)onCloseButtonClickedInRecordDetailView:(id)sender
{
    [CRModal dismiss];
}

@end
