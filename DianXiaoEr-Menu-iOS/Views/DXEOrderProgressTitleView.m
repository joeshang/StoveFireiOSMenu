//
//  DXEOrderProgressTitleView.m
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 9/25/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "DXEOrderProgressTitleView.h"

@implementation DXEOrderProgressTitleView

- (void)awakeFromNib
{
    UIColor *titleColor = [[RNThemeManager sharedManager] colorForKey:@"NormalColor"];
    self.nameTitle.textColor = titleColor;
    self.progressTitle.textColor = titleColor;
    self.countTitle.textColor = titleColor;
    self.priceTitle.textColor = titleColor;
    
    self.contentView.clipsToBounds = YES;
    self.contentView.layer.cornerRadius = kDXECommonCornerRadius;
    self.contentView.layer.borderWidth = kDXECommonBorderWidth;
    self.contentView.layer.borderColor = [[[RNThemeManager sharedManager] colorForKey:@"BorderColor"] CGColor];;
    
    self.backgroundColor = [[RNThemeManager sharedManager] colorForKey:@"BackgroundColor"];
}

@end
