//
//  CRScrollMenuController.h
//  CRScrollMenuController
//
//  Created by Joe Shang on 9/10/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CRScrollMenu.h"

@interface CRScrollMenuController : UIViewController

@property (nonatomic, strong) NSArray *viewControllers;

@property (nonatomic, assign) NSUInteger scrollMenuHeight;
@property (nonatomic, strong) UIImage *scrollMenuBackgroundImage;
@property (nonatomic, strong) UIColor *scrollMenuBackgroundColor;

@property (nonatomic, assign) NSUInteger scrollMenuIndicatorHeight;
@property (nonatomic, strong) UIColor *scrollMenuIndicatorColor;

@property (nonatomic, assign) NSUInteger scrollMenuButtonPadding;
@property (nonatomic, strong) NSDictionary *normalTitleAttributes;
@property (nonatomic, strong) NSDictionary *selectedTitleAttributes;
@property (nonatomic, strong) NSDictionary *normalSubtitleAttributes;
@property (nonatomic, strong) NSDictionary *selectedSubtitleAttributes;

- (void)setViewControllers:(NSArray *)viewControllers withItems:(NSArray *)items;
- (void)setSelectedAtIndex:(NSUInteger)currentIndex;

- (NSUInteger)currentIndex;

@end
