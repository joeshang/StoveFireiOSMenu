//
//  SFEnsureOrderingView.m
//  StoveFireiOSMenu
//
//  Created by Joe Shang on 9/17/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "SFEnsureOrderingView.h"

@implementation SFEnsureOrderingView

- (void)awakeFromNib
{
    self.priceView.clipsToBounds = YES;
    self.priceView.layer.cornerRadius = kSFCommonCornerRadius;
    self.priceView.layer.borderWidth = kSFCommonBorderWidth;
    self.priceView.layer.borderColor = [[[RNThemeManager sharedManager] colorForKey:@"BorderColor"] CGColor];;
}

@end
