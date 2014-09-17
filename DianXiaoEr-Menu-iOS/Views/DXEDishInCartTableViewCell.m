//
//  DXEDishInCartTableViewCell.m
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 9/17/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "DXEDishInCartTableViewCell.h"

@implementation DXEDishInCartTableViewCell

- (void)awakeFromNib
{
    self.dishName.textColor = [[RNThemeManager sharedManager] colorForKey:@"Order.DishCell.NameFontColor"];
    self.dishEnglishName.textColor = [[RNThemeManager sharedManager] colorForKey:@"Order.DishCell.NameFontColor"];
    self.dishPrice.textColor = [[RNThemeManager sharedManager] colorForKey:@"Order.DishCell.PriceFontColor"];
    self.dishCount.textColor = [[RNThemeManager sharedManager] colorForKey:@"Order.DishCell.CountFontColor"];
}

- (void)updateDishCountButtonsByCount:(NSInteger)count
{
    self.dishCount.text = [NSString stringWithFormat:@"%ld", count];
    if (count == kDXEDishItemCountInCartMin)
    {
        self.decreaseButton.enabled = NO;
        self.decreaseButton.backgroundColor = [UIColor lightGrayColor];
    }
    else if (count == kDXEDishItemCountInCartMax)
    {
        self.increaseButton.enabled = NO;
        self.increaseButton.backgroundColor = [UIColor lightGrayColor];
    }
    else
    {
        self.decreaseButton.enabled = YES;
        self.increaseButton.enabled = YES;
        self.decreaseButton.backgroundColor = [UIColor blueColor];
        self.increaseButton.backgroundColor = [UIColor blueColor];
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
        void (*func)(id, SEL, DXEDishInCartTableViewCell *) = (void *)imp;
        func(self.controller, selector, self);
    }
}

@end
