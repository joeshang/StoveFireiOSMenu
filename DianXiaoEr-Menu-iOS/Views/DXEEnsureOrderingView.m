//
//  DXEEnsureOrderingView.m
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 9/17/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "DXEEnsureOrderingView.h"

@implementation DXEEnsureOrderingView

- (void)awakeFromNib
{
    UIColor *fontColor = [[RNThemeManager sharedManager] colorForKey:@"Order.EnsureOrdering.FontColor"];
    self.totalPrice.textColor = fontColor;
    self.totalPriceTitle.textColor = fontColor;
    
    self.priceView.layer.cornerRadius = kDXEOrderTitleViewRadius;
    self.priceView.layer.borderWidth = kDXEOrderTitleViewBorderWidth;
    self.priceView.layer.borderColor = [[[RNThemeManager sharedManager] colorForKey:@"Order.TitleView.BorderColor"] CGColor];;
}

@end
