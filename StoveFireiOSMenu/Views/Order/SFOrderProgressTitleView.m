//
//  SFOrderProgressTitleView.m
//  StoveFireiOSMenu
//
//  Created by Joe Shang on 9/25/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "SFOrderProgressTitleView.h"

@implementation SFOrderProgressTitleView

- (void)awakeFromNib
{
    self.contentView.clipsToBounds = YES;
    self.contentView.layer.cornerRadius = kSFCommonCornerRadius;
    self.contentView.layer.borderWidth = kSFCommonBorderWidth;
    self.contentView.layer.borderColor = [[[RNThemeManager sharedManager] colorForKey:@"BorderColor"] CGColor];;
    
    self.backgroundColor = [[RNThemeManager sharedManager] colorForKey:@"BackgroundColor"];
}

@end
