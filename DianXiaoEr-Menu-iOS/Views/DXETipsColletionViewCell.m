//
//  DXETipsColletionViewCell.m
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 8/3/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "DXETipsColletionViewCell.h"

@implementation DXETipsColletionViewCell

- (void)awakeFromNib
{
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = kDXECommonCornerRadius;
    self.layer.borderWidth = kDXECommonBorderWidth;
    self.layer.borderColor = [[[RNThemeManager sharedManager] colorForKey:@"BorderColor"] CGColor];
}

@end
