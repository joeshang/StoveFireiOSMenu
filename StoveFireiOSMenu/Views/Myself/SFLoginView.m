//
//  SFMemberLoginView.m
//  StoveFireiOSMenu
//
//  Created by Joe Shang on 9/25/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "SFLoginView.h"
#import "CRModal.h"

@implementation SFLoginView

- (void)awakeFromNib
{
    self.backgroundColor = [[RNThemeManager sharedManager] colorForKey:@"NormalColor"];
}

- (void)setUserNamePlaceholder:(NSString *)userNamePlaceholder
{
    UIColor *color = [[RNThemeManager sharedManager] colorForKey:@"Login.HighlightColor"];
    NSDictionary *attributes = @{
                                 NSFontAttributeName: [UIFont systemFontOfSize:18],
                                 NSForegroundColorAttributeName: color
                                 };
    self.userName.attributedPlaceholder = [[NSAttributedString alloc]
                                           initWithString:userNamePlaceholder
                                           attributes:attributes];
    self.password.attributedPlaceholder = [[NSAttributedString alloc]
                                           initWithString:@"输入密码"
                                           attributes:attributes];
}

- (IBAction)onCloseButtonClicked:(id)sender
{
    [CRModal dismiss];
}

- (IBAction)onLoginButtonClicked:(id)sender
{
    SEL selector = NSSelectorFromString(@"onLoginButtonClickedInLoginView:");
    [self notificateControllerWithSelector:selector];
}

- (void)notificateControllerWithSelector:(SEL)selector
{
    if ([self.controller respondsToSelector:selector])
    {
        // func is a trick for performSelector:withObject without "may cause a leak because its selector is unknown" warning
        // [self.controller performSelector:selector
        //                       withObject:self
        IMP imp = [self.controller methodForSelector:selector];
        void (*func)(id, SEL, SFLoginView*) = (void *)imp;
        func(self.controller, selector, self);
    }
}

@end
