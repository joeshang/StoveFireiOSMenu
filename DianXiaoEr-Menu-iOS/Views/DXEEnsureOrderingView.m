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
    
    self.priceView.clipsToBounds = YES;
    self.priceView.layer.cornerRadius = kDXECommonCornerRadius;
    self.priceView.layer.borderWidth = kDXECommonBorderWidth;
    self.priceView.layer.borderColor = [[[RNThemeManager sharedManager] colorForKey:@"BorderColor"] CGColor];;
}

@end
