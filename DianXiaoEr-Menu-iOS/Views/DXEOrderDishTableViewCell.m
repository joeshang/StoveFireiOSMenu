//
//  DXEDishInCartTableViewCell.m
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 9/17/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "DXEOrderDishTableViewCell.h"

@implementation DXEOrderDishTableViewCell

- (void)awakeFromNib
{
    self.contentView.backgroundColor = [[RNThemeManager sharedManager] colorForKey:@"BackgroundColor"];
    self.backgroundImageView.image = [[RNThemeManager sharedManager] imageForName:@"order_cell_background.png"];
    self.backgroundImageView.backgroundColor = [[RNThemeManager sharedManager] colorForKey:@"Cell.BackgroundColor"];
    
    UIColor *highlightColor = [[RNThemeManager sharedManager] colorForKey:@"HighlightColor"];
    self.dishName.textColor = highlightColor;
    self.dishEnglishName.textColor = highlightColor;

    UIColor *normalColor = [[RNThemeManager sharedManager] colorForKey:@"NormalColor"];
    self.dishCount.textColor = normalColor;
    self.dishPrice.textColor = normalColor;
    self.dishTotalPrice.textColor = normalColor;
}

- (void)updateCellByDishCount:(NSInteger)count dishPrice:(float)price;
{
    self.dishCount.text = [NSString stringWithFormat:@"%d", (int)count];
    self.dishTotalPrice.text = [NSString stringWithFormat:@"￥%.2f", count * price];
    
    if (count == kDXEDishItemCountInCartMin)
    {
        self.decreaseButton.enabled = NO;
    }
    else if (count == kDXEDishItemCountInCartMax)
    {
        self.increaseButton.enabled = NO;
    }
    else
    {
        self.decreaseButton.enabled = YES;
        self.increaseButton.enabled = YES;
    }
}

- (IBAction)onIncreaseButtonClicked:(id)sender
{
    SEL selector = NSSelectorFromString(@"onIncreaseButtonClickedInTableCell:");
    [self notificateControllerWithSelector:selector];
}

- (IBAction)onDecreaseButtonClicked:(id)sender
{
    SEL selector = NSSelectorFromString(@"onDecreaseButtonClickedInTableCell:");
    [self notificateControllerWithSelector:selector];
}

- (IBAction)onDeleteButtonClicked:(id)sender
{
    SEL selector = NSSelectorFromString(@"onDeleteButtonClickedInTableCell:");
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
        void (*func)(id, SEL, DXEOrderDishTableViewCell *) = (void *)imp;
        func(self.controller, selector, self);
    }
}

@end
