//
//  DXEMyselfViewController.m
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 7/15/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "DXEMyselfViewController.h"
#import "DXEMember.h"
#import "DXERecordTableViewCell.h"
#import "DXEDiningRecord.h"
#import "DXERecordTitleView.h"
#import "DXERecordDetailView.h"
#import "CRModal.h"

@interface DXEMyselfViewController ()

@property (nonatomic, strong) DXERecordTitleView *titleView;
@property (nonatomic, strong) DXEDiningRecord *detailedRecord;

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
    
    NSString *nibName = NSStringFromClass([DXERecordTitleView class]);
    self.titleView = [[[NSBundle mainBundle] loadNibNamed:nibName
                                                   owner:self
                                                  options:nil] firstObject];
    
    nibName = NSStringFromClass([DXERecordTableViewCell class]);
    [self.recordTableView registerNib:[UINib nibWithNibName:nibName bundle:nil]
               forCellReuseIdentifier:nibName];
    self.recordTableView.backgroundColor = backgroundColor;
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
        return 0;//[self.detailedRecord.dishes count];
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
        return nil;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView == self.recordTableView)
    {
        return self.titleView;
    }
    else
    {
        return nil;
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
        self.recordEmptyTips.image = [[RNThemeManager sharedManager] imageForKey:@"myself_record_empty_flag.png"];
    }
    
    [self.recordTableView reloadData];
}

#pragma mark - notification

- (void)onDetailButtonClickedInTableCell:(DXERecordTableViewCell *)cell
{
    NSIndexPath *indexPath = [self.recordTableView indexPathForCell:cell];
    self.detailedRecord = [self.member.records objectAtIndex:indexPath.row];
    DXERecordDetailView *recordDetailView =
    [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([DXERecordDetailView class])
                                   owner:self
                                 options:nil] firstObject];
    CGFloat height = 0.0;
    if ([self.detailedRecord.dishes count] >= 4)
    {
        height = 730;
    }
    else
    {
        height = 170 + 140 * [self.detailedRecord.dishes count];
    }
    CGRect rect = recordDetailView.frame;
    rect.size.height = height;
    recordDetailView.frame = rect;

    [CRModal showModalView:recordDetailView
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
