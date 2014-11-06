//
//  SFDishDetailView.m
//  StoveFireiOSMenu
//
//  Created by Joe Shang on 9/4/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "SFDishDetailView.h"

#define kSFDishDetailViewCornerRadius              15

@implementation SFDishDetailView

- (void)awakeFromNib
{
    UIColor *borderColor = [[RNThemeManager sharedManager] colorForKey:@"BorderColor"];
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = kSFDishDetailViewCornerRadius;
    self.layer.borderWidth = kSFCommonBorderWidth;
    self.layer.borderColor = [borderColor CGColor];
    
    self.backgroundColor = [[RNThemeManager sharedManager] colorForKey:@"BackgroundColor"];
}

@end
