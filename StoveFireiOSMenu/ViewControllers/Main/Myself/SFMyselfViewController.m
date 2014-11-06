//
//  SFMyselfViewController.m
//  StoveFireiOSMenu
//
//  Created by Joe Shang on 7/15/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "SFMyselfViewController.h"
#import "SFMember.h"
#import "SFRecordTableViewCell.h"
#import "SFDiningRecord.h"
#import "SFImageManager.h"
#import "SFRecordTitleView.h"
#import "SFRecordDetailView.h"
#import "SFRecordDetailFooterView.h"
#import "SFOrderCartTableViewCell.h"
#import "SFOrderCartTitleView.h"
#import "SFRecordDishItem.h"
#import "CRModal.h"

#define kSFRecordDetailCellWidth           594
#define kSFRecordDetailCellHeight          140
#define kSFRecordDetailExceptCellHeight    180
#define kSFRecordDetailMaxShowCount        4
#define kSFRecordDetailCountCenterX        352
#define kSFRecordDetailTotalPriceCenterX   497

@interface SFMyselfViewController ()

@property (nonatomic, strong) SFDiningRecord *detailedRecord;
@property (nonatomic, strong) SFRecordDetailView *recordDetailView;
@property (nonatomic, strong) SFRecordDetailFooterView *recordDetailFooterView;

@end

@implementation SFMyselfViewController

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
    
    NSString *nibName = NSStringFromClass([SFRecordTableViewCell class]);
    [self.recordTableView registerNib:[UINib nibWithNibName:nibName bundle:nil]
               forCellReuseIdentifier:nibName];
    self.recordTableView.backgroundColor = backgroundColor;
    
    nibName = NSStringFromClass([SFRecordDetailView class]);
    self.recordDetailView = [[[NSBundle mainBundle] loadNibNamed:nibName
                                                           owner:self
                                                         options:nil] firstObject];
    nibName = NSStringFromClass([SFOrderCartTableViewCell class]);
    [self.recordDetailView.dishesTableView registerNib:[UINib nibWithNibName:nibName bundle:nil] forCellReuseIdentifier:nibName];
    
    nibName = NSStringFromClass([SFRecordDetailFooterView class]);
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
        SFDiningRecord *record = [self.member.records objectAtIndex:indexPath.row];
        
        NSString *identifier = NSStringFromClass([SFRecordTableViewCell class]);
        SFRecordTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        cell.controller = self;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
        NSDate *dinnerDate = [formatter dateFromString:record.date];
        formatter.dateFormat = @"yyyy.MM.dd   HH:mm";
        cell.date.text = [formatter stringFromDate:dinnerDate];
        
        int dishCount = 0;
        float totalPrice = 0.0;
        for (SFRecordDishItem *item in record.dishes)
        {
            dishCount += [item.count intValue];
            totalPrice += [item.price floatValue] * [item.count intValue];
        }
        cell.dishCount.text = [NSString stringWithFormat:@"%d", dishCount];
        cell.totalPrice.text = [NSString stringWithFormat:@"￥%.2f", totalPrice];
        
        return cell;
    }
    else
    {
        SFRecordDishItem *item = [self.detailedRecord.dishes objectAtIndex:indexPath.row];
        
        NSString *identifier = NSStringFromClass([SFOrderCartTableViewCell class]);
        SFOrderCartTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        cell.dishName.text = item.name;
        cell.dishEnglishName.text = item.englishName;
        cell.dishCount.text = [item.count stringValue];
        cell.dishPrice.text = [NSString stringWithFormat:@"单价：￥%.2f", [item.price floatValue]];
        cell.dishTotalPrice.text = [NSString stringWithFormat:@"￥%.2f", [item.price floatValue] * [item.count integerValue]];
        UIImage *thumbnail = [[SFImageManager sharedInstance] imageForKey:item.thumbnailKey];
        if (!thumbnail)
        {
            thumbnail = [[RNThemeManager sharedManager] imageForKey:@"myself_record_dish_placeholder.png"];
        }
        cell.dishThumbnail.image = thumbnail;
        cell.increaseButton.hidden = YES;
        cell.decreaseButton.hidden = YES;
        cell.countUnderline.hidden = YES;
        cell.deleteButton.hidden = YES;
        if ([item.vip boolValue])
        {
            cell.dishVipFlag.hidden = NO;
        }
        else
        {
            cell.dishVipFlag.hidden = YES;
        }
        CGPoint center = cell.dishCount.center;
        center.x = kSFRecordDetailCountCenterX;
        cell.dishCount.center = center;
        center = cell.dishTotalPrice.center;
        center.x = kSFRecordDetailTotalPriceCenterX;
        cell.dishTotalPrice.center = center;
        cell.backgroundImageView.image = [[RNThemeManager sharedManager] imageForKey:@"myself_record_detail_cell_background.png"];
        CGRect frame = cell.frame;
        frame.size.width = kSFRecordDetailCellWidth;
        cell.frame = frame;
        
        return cell;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView == self.recordTableView)
    {
        NSString *nibName = NSStringFromClass([SFRecordTitleView class]);
        SFRecordTitleView *titleView = [[[NSBundle mainBundle] loadNibNamed:nibName
                                                                       owner:self
                                                                     options:nil] firstObject];
        return titleView;
    }
    else
    {
        NSString *nibName = NSStringFromClass([SFOrderCartTitleView class]);
        SFOrderCartTitleView *titleView = [[[NSBundle mainBundle] loadNibNamed:nibName
                                                                       owner:self
                                                                     options:nil] firstObject];
        titleView.nameTitle.text = @"菜品";
        CGRect frame = titleView.frame;
        frame.size.width = kSFRecordDetailCellWidth;
        titleView.frame = frame;
        CGPoint center = titleView.countTitle.center;
        center.x = kSFRecordDetailCountCenterX;
        titleView.countTitle.center = center;
        center = titleView.totalPriceTitle.center;
        center.x = kSFRecordDetailTotalPriceCenterX;
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

- (void)setMember:(SFMember *)member
{
    _member = member;
    
    self.memberName.text = member.memberName;
    self.memberPhone.text = member.memberPhone;
    self.memberAccount.text = [NSString stringWithFormat:@"%@ 元", member.memberAccount];
    if (!member.records || [member.records count] == 0)
    {
        self.recordEmptyTips.hidden = NO;
    }
    
    [self.recordTableView reloadData];
}

#pragma mark - notification

- (void)onDetailButtonClickedInTableCell:(SFRecordTableViewCell *)cell
{
    NSIndexPath *indexPath = [self.recordTableView indexPathForCell:cell];
    self.detailedRecord = [self.member.records objectAtIndex:indexPath.row];
    NSInteger showCount = kSFRecordDetailMaxShowCount;
    if ([self.detailedRecord.dishes count] < kSFRecordDetailMaxShowCount)
    {
        showCount = [self.detailedRecord.dishes count];
    }
    CGRect rect = self.recordDetailView.frame;
    rect.size.height = kSFRecordDetailExceptCellHeight + showCount * kSFRecordDetailCellHeight;
    self.recordDetailView.frame = rect;
    self.recordDetailFooterView.totalPrice.text = cell.totalPrice.text;
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
