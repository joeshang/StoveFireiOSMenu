//
//  DXERecordTitleView.m
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 9/23/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "DXERecordTitleView.h"

@implementation DXERecordTitleView

- (void)awakeFromNib
{
    UIColor *titleColor = [[RNThemeManager sharedManager] colorForKey:@"NormalColor"];
    self.recordTitle.textColor = titleColor;
    self.dateTitle.textColor = titleColor;
    self.dishCountTitle.textColor = titleColor;
    self.totalPriceTitle.textColor = titleColor;
    self.detailTitle.textColor = titleColor;
    
    self.contentView.clipsToBounds = YES;
    self.contentView.layer.cornerRadius = kDXECommonCornerRadius;
    self.contentView.layer.borderWidth = kDXECommonBorderWidth;
    self.contentView.layer.borderColor = [[[RNThemeManager sharedManager] colorForKey:@"BorderColor"] CGColor];;
    
    self.backgroundColor = [[RNThemeManager sharedManager] colorForKey:@"BackgroundColor"];
}

@end
