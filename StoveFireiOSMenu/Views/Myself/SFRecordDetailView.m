//
//  SFRecordDetailView.m
//  StoveFireiOSMenu
//
//  Created by Joe Shang on 9/27/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "SFRecordDetailView.h"

@implementation SFRecordDetailView

- (void)awakeFromNib
{
    UIColor *color = [[RNThemeManager sharedManager] colorForKey:@"BackgroundColor"];
    self.dishesTableView.backgroundColor = color;
    self.backgroundColor = color;
    self.clipsToBounds = YES;
    self.layer.cornerRadius = kSFCommonCornerRadius;
    self.layer.borderWidth = kSFCommonBorderWidth;
    self.layer.borderColor = [[[RNThemeManager sharedManager] colorForKey:@"BorderColor"] CGColor];;
}

@end
