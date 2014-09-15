//
//  CRScrollMenuButton.h
//  CRScrollMenu
//
//  Created by Joe Shang on 8/24/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CRScrollMenuButton : UIControl

@property (nonatomic, copy)   NSString *title;
@property (nonatomic, copy)   NSString *subtitle;

@property (nonatomic, assign) NSUInteger titleSpacing;

@property (nonatomic, strong) NSDictionary *normalTitleAttributes;
@property (nonatomic, strong) NSDictionary *selectedTitleAttributes;
@property (nonatomic, strong) NSDictionary *normalSubtitleAttributes;
@property (nonatomic, strong) NSDictionary *selectedSubtitleAttributes;

@end
