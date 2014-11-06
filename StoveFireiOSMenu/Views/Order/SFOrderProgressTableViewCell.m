//
//  SFOrderProgressTableViewCell.m
//  StoveFireiOSMenu
//
//  Created by Joe Shang on 9/24/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "SFOrderProgressTableViewCell.h"

@implementation SFOrderProgressTableViewCell

- (void)awakeFromNib
{
    self.contentView.backgroundColor = [[RNThemeManager sharedManager] colorForKey:@"BackgroundColor"];
    self.backgroundImageView.image = [[RNThemeManager sharedManager] imageForKey:@"order_progress_cell_background.png"];
    self.backgroundImageView.backgroundColor = [[RNThemeManager sharedManager] colorForKey:@"BackgroundColor"];
    
    UIColor *highlightColor = [[RNThemeManager sharedManager] colorForKey:@"HighlightColor"];
    UIColor *normalColor = [[RNThemeManager sharedManager] colorForKey:@"NormalColor"];
    
    self.dishName.textColor = highlightColor;
    self.dishEnglishName.textColor = highlightColor;

    self.dishCount.textColor = normalColor;
    self.dishPrice.textColor = normalColor;
    self.dishTotalPrice.textColor = normalColor;
    
    self.state = SFDishProgressTodo;
}

- (void)setState:(SFDishProgress)cellState
{
    UIColor *highlightColor = [[RNThemeManager sharedManager] colorForKey:@"HighlightColor"];
    UIColor *darkenColor = [[RNThemeManager sharedManager] colorForKey:@"DarkenColor"];
    UIImage *lightPoint = [[RNThemeManager sharedManager] imageForKey:@"order_progress_light_point.png"];
    UIImage *darkPoint = [[RNThemeManager sharedManager] imageForKey:@"order_progress_dark_point.png"];
    
    switch (cellState) {
        case SFDishProgressTodo:
        {
            self.todoTitle.textColor = highlightColor;
            self.todoPoint.image = lightPoint;
            self.doingTitle.textColor = darkenColor;
            self.doingLine.backgroundColor = darkenColor;
            self.doingPoint.image = darkPoint;
            self.doneTitle.textColor = darkenColor;
            self.doneLine.backgroundColor = darkenColor;
            self.donePoint.image = darkPoint;
            
            break;
        }
        case SFDishProgressDoing:
        {
            self.todoTitle.textColor = highlightColor;
            self.todoPoint.image = lightPoint;
            self.doingTitle.textColor = highlightColor;
            self.doingLine.backgroundColor = highlightColor;
            self.doingPoint.image = lightPoint;
            self.doneTitle.textColor = darkenColor;
            self.doneLine.backgroundColor = darkenColor;
            self.donePoint.image = darkPoint;
            
            break;
        }
        case SFDishProgressDone:
        {
            self.todoTitle.textColor = highlightColor;
            self.todoPoint.image = lightPoint;
            self.doingTitle.textColor = highlightColor;
            self.doingLine.backgroundColor = highlightColor;
            self.doingPoint.image = lightPoint;
            self.doneTitle.textColor = highlightColor;
            self.doneLine.backgroundColor = highlightColor;
            self.donePoint.image = lightPoint;
            
            break;
        }
        default:
            break;
    }
    
    _state = cellState;
}

@end
