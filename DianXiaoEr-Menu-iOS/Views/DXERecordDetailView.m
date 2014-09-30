//
//  DXERecordDetailView.m
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 9/27/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "DXERecordDetailView.h"

@implementation DXERecordDetailView

- (void)awakeFromNib
{
    UIColor *color = [[RNThemeManager sharedManager] colorForKey:@"BackgroundColor"];
    self.dishesTableView.backgroundColor = color;
    self.backgroundColor = color;
    self.clipsToBounds = YES;
    self.layer.cornerRadius = kDXECommonCornerRadius;
    self.layer.borderWidth = kDXECommonBorderWidth;
    self.layer.borderColor = [[[RNThemeManager sharedManager] colorForKey:@"BorderColor"] CGColor];;
}

@end
