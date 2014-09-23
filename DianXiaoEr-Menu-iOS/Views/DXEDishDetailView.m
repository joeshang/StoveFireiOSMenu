//
//  DXEDishDetailView.m
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 9/4/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "DXEDishDetailView.h"

#define kDXEDishDetailViewCornerRadius              15

@implementation DXEDishDetailView

- (void)awakeFromNib
{
    UIColor *borderColor = [[RNThemeManager sharedManager] colorForKey:@"BorderColor"];
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = kDXEDishDetailViewCornerRadius;
    self.layer.borderWidth = kDXECommonBorderWidth;
    self.layer.borderColor = [borderColor CGColor];
    self.separator.backgroundColor = borderColor;
    
    self.backgroundColor = [[RNThemeManager sharedManager] colorForKey:@"BackgroundColor"];
    UIColor *tintColor = [[RNThemeManager sharedManager] colorForKey:@"DarkenColor"];
    self.dishName.textColor = tintColor;
    self.dishEnglishName.textColor = tintColor;
    self.dishPrice.textColor = tintColor;
    self.dishFavor.textColor = tintColor;
    self.dishIngredient.textColor = tintColor;
}

@end
