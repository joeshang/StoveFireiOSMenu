//
//  DXERecordDetailFooterView.m
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 9/30/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "DXERecordDetailFooterView.h"

@implementation DXERecordDetailFooterView

- (void)awakeFromNib
{
    self.contentView.clipsToBounds = YES;
    self.contentView.layer.cornerRadius = kDXECommonCornerRadius;
    self.contentView.layer.borderWidth = kDXECommonBorderWidth;
    self.contentView.layer.borderColor = [[[RNThemeManager sharedManager] colorForKey:@"BorderColor"] CGColor];;
    
    self.backgroundColor = [[RNThemeManager sharedManager] colorForKey:@"BackgroundColor"];
}

@end
