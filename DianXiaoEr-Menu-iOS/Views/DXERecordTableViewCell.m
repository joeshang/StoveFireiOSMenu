//
//  DXERecordTableViewCell.m
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 9/22/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "DXERecordTableViewCell.h"

@implementation DXERecordTableViewCell

- (void)awakeFromNib
{
    self.contentView.backgroundColor = [[RNThemeManager sharedManager] colorForKey:@"BackgroundColor"];
    self.backgroundImageView.image = [[RNThemeManager sharedManager] imageForName:@"myself_record_cell_background.png"];
    self.backgroundImageView.backgroundColor = [[RNThemeManager sharedManager] colorForKey:@"Cell.BackgroundColor"];
    
    self.brand.image = [[RNThemeManager sharedManager] imageForName:@"myself_record_brand.png"];
    
    UIColor *fontColor = [[RNThemeManager sharedManager] colorForKey:@"HighlightColor"];
    self.date.textColor = fontColor;
    self.dishCount.textColor = fontColor;
    self.totalPrice.textColor = fontColor;
    
    [self.detailButton setImage:[[RNThemeManager sharedManager] imageForName:@"myself_record_detail_button.png"]
                       forState:UIControlStateNormal];
}

- (IBAction)onDetailButtonClicked:(id)sender
{
    SEL selector = NSSelectorFromString(@"onDetailButtonClickedInTableCell:");
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
        void (*func)(id, SEL, DXERecordTableViewCell*) = (void *)imp;
        func(self.controller, selector, self);
    }
}

@end
