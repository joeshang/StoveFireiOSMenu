//
//  SFDishInCartTableViewCell.m
//  StoveFireiOSMenu
//
//  Created by Joe Shang on 9/17/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "SFOrderCartTableViewCell.h"

@implementation SFOrderCartTableViewCell

- (void)awakeFromNib
{
    self.contentView.backgroundColor = [[RNThemeManager sharedManager] colorForKey:@"BackgroundColor"];
    self.backgroundImageView.image = [[RNThemeManager sharedManager] imageForKey:@"order_cell_background.png"];
    self.backgroundImageView.backgroundColor = [[RNThemeManager sharedManager] colorForKey:@"BackgroundColor"];
}

- (void)updateCellByDishCount:(NSInteger)count dishPrice:(float)price;
{
    self.dishCount.text = [NSString stringWithFormat:@"%d", (int)count];
    self.dishTotalPrice.text = [NSString stringWithFormat:@"￥%.2f", count * price];
    
    if (count == kSFDishItemCountInCartMin)
    {
        self.decreaseButton.enabled = NO;
    }
    else if (count == kSFDishItemCountInCartMax)
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
        void (*func)(id, SEL, SFOrderCartTableViewCell *) = (void *)imp;
        func(self.controller, selector, self);
    }
}

@end
