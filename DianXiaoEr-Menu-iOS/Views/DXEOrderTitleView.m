//
//  DXEOrderTitleView.m
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 9/18/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "DXEOrderTitleView.h"

@implementation DXEOrderTitleView

- (void)awakeFromNib
{
    UIColor *titleColor = [[RNThemeManager sharedManager] colorForKey:@"Order.TitleView.TitleFontColor"];
    self.nameTitle.textColor = titleColor;
    self.countTitle.textColor = titleColor;
    self.priceTitle.textColor = titleColor;
    
    self.contentView.layer.cornerRadius = kDXEOrderTitleViewRadius;
    self.contentView.layer.borderWidth = kDXEOrderTitleViewBorderWidth;
    self.contentView.layer.borderColor = [[[RNThemeManager sharedManager] colorForKey:@"Order.TitleView.BorderColor"] CGColor];;
}

@end
