//
//  SFRecordTableViewCell.m
//  StoveFireiOSMenu
//
//  Created by Joe Shang on 9/22/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "SFRecordTableViewCell.h"

@implementation SFRecordTableViewCell

- (void)awakeFromNib
{
    self.contentView.backgroundColor = [[RNThemeManager sharedManager] colorForKey:@"BackgroundColor"];
    self.backgroundImageView.backgroundColor = [[RNThemeManager sharedManager] colorForKey:@"Cell.BackgroundColor"];
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
        void (*func)(id, SEL, SFRecordTableViewCell*) = (void *)imp;
        func(self.controller, selector, self);
    }
}

@end
