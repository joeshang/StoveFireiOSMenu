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

@interface DXEMyselfViewController ()

@property (nonatomic, strong) DXERecordTitleView *titleView;

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
    
    UIColor *highlightColor = [[RNThemeManager sharedManager] colorForKey:@"HighlightColor"];
    UIColor *normalColor = [[RNThemeManager sharedManager] colorForKey:@"NormalColor"];
    
    UIImage *underline = [[RNThemeManager sharedManager] imageForName:@"myself_title_underline.png"];
    self.accountTitle.textColor = highlightColor;
    self.recordTitle.textColor = highlightColor;
    self.accountUnderline.image = underline;
    self.recordUnderline.image = underline;
    
    self.memberName.textColor = highlightColor;
    self.memberPhone.textColor = highlightColor;
    self.memberAccount.textColor = highlightColor;
    self.memberNameTitle.textColor = normalColor;
    self.memberPhoneTitle.textColor = normalColor;
    self.memberAccountTitle.textColor = normalColor;
    self.memberNameIcon.image = [[RNThemeManager sharedManager] imageForName:@"myself_member_name_icon.png"];
    self.memberPhoneIcon.image = [[RNThemeManager sharedManager] imageForName:@"myself_member_phone_icon.png"];
    self.memberAccountIcon.image = [[RNThemeManager sharedManager] imageForName:@"myself_member_account_icon.png"];
    
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
    return [self.member.records count];
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return self.titleView;
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
        self.recordEmptyTips.image = [[RNThemeManager sharedManager] imageForName:@"myself_record_empty_flag.png"];
    }
    
    [self.recordTableView reloadData];
}

#pragma mark - notification

- (void)onDetailButtonClickedInTableCell:(DXERecordTableViewCell *)cell
{
    
}


@end
