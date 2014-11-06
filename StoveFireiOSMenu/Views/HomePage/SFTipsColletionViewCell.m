//
//  SFTipsColletionViewCell.m
//  StoveFireiOSMenu
//
//  Created by Joe Shang on 8/3/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "SFTipsColletionViewCell.h"

@implementation SFTipsColletionViewCell

- (void)awakeFromNib
{
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = kSFCommonCornerRadius;
    self.layer.borderWidth = kSFCommonBorderWidth;
    self.layer.borderColor = [[[RNThemeManager sharedManager] colorForKey:@"BorderColor"] CGColor];
}

@end
