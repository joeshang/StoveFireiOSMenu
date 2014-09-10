//
//  DXEDishDetailView.m
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 9/4/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "DXEDishDetailView.h"

@implementation DXEDishDetailView

- (void)awakeFromNib
{
    self.layer.cornerRadius = kDXEDishDetailViewRadius;
    self.layer.masksToBounds = YES;
    self.layer.borderWidth = kDXEDishDetailViewBorderWidth;
    self.layer.borderColor = [[[RNThemeManager sharedManager] colorForKey:@"HomePage.CollectionViewCell.BorderColor"] CGColor];
    
    self.backgroundColor = [[RNThemeManager sharedManager] colorForKey:@"HomePage.CollectionViewCell.BackgroundColor"];
    UIColor *tintColor = [[RNThemeManager sharedManager] colorForKey:@"HomePage.CollectionViewCell.TintColor"];
    self.dishName.textColor = tintColor;
    self.dishEnglishName.textColor = tintColor;
    self.dishPrice.textColor = tintColor;
    self.dishFavor.textColor = tintColor;
    self.dishIngredient.textColor = tintColor;
}

@end
