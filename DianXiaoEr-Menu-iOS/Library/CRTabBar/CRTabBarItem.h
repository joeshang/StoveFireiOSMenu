//
//  CRTabBarItem.h
//  CRTabBar
//
//  Created by Joe Shang on 9/21/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CRTabBarItem : UIControl

- (id)initWithTitle:(NSString *)title
        normalImage:(UIImage *)normalImage
      selectedImage:(UIImage *)selectedImage;

@property (nonatomic, copy)   NSString *title;
@property (nonatomic, assign) UIOffset titlePositionAdjustment;
@property (nonatomic, copy)   NSDictionary *normalTitleAttributes;
@property (nonatomic, copy)   NSDictionary *selectedTitleAttributes;

@property (nonatomic, assign) UIOffset imagePositionAdjustment;
- (void)setNormalImage:(UIImage *)normalImage
     withSelectedImage:(UIImage *)selectedImage;
- (void)setNormalBackgroundImage:(UIImage *)normalImage
     withSelectedBackgroundImage:(UIImage *)selectedImage;

@property (nonatomic, copy)   NSString *badgeValue;
@property (nonatomic, assign) UIOffset badgePositionAdjustment;
@property (nonatomic, strong) UIFont  *badgeTextFont;
@property (nonatomic, strong) UIColor *badgeTextColor;
@property (nonatomic, strong) UIImage *badgeBackgroundImage;
@property (nonatomic, strong) UIColor *badgeBackgroundColor;

@end
