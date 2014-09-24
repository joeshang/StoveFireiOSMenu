//
//  DXEMemberLoginView.m
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 9/25/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "DXEMemberLoginView.h"

@implementation DXEMemberLoginView

- (void)awakeFromNib
{
    UIColor *color = [UIColor colorWithHexString:@"BE9C54"];
    NSDictionary *attributes = @{
                                 NSFontAttributeName: [UIFont systemFontOfSize:18],
                                 NSForegroundColorAttributeName: color
                                 };
    self.userName.attributedPlaceholder = [[NSAttributedString alloc]
                                           initWithString:@"会员卡号/手机号码"
                                           attributes:attributes];
    self.password.attributedPlaceholder = [[NSAttributedString alloc]
                                           initWithString:@"输入密码"
                                           attributes:attributes];
}

@end
