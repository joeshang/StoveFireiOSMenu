//
//  CRTabBar.h
//  CRTabBar
//
//  Created by Joe Shang on 9/21/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CRTabBar;

@protocol CRTabBarDelegate <NSObject>

- (BOOL)tabBar:(CRTabBar *)tabBar shouldSelecteItemAtIndex:(NSInteger)index;
- (void)tabBar:(CRTabBar *)tabBar didSelectItemAtIndex:(NSInteger)index;

@end

@interface CRTabBar : UIView

@property (nonatomic, weak) id<CRTabBarDelegate> delegate;

@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) UIEdgeInsets contentEdgeInsets;
@property (nonatomic, strong) UIImage *backgroundImage;
@property (nonatomic, strong) NSArray *items;

- (NSInteger)selectedIndex;
- (void)setItemSelectedAtIndex:(NSInteger)index;

@end
