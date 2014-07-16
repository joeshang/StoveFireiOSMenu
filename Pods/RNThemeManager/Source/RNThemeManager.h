//
//  RNThemeManager.h
//
//  Created by Ryan Nystrom on 12/2/12.
//  Copyright (c) 2012 Ryan Nystrom. All rights reserved.
//

#import <Foundation/Foundation.h>

// Fired every time @property style is changed (except during init)
extern NSString * const RNThemeManagerDidChangeThemes;

@interface RNThemeManager : NSObject

// Singleton
+ (RNThemeManager*)sharedManager;

// Dictionary of all styles for the current theme. KVO compatible but Notification is sent when changed.
@property (nonatomic, strong, readonly) NSDictionary *styles;

// Read the selected theme name
@property (nonatomic, strong, readonly) NSString *currentThemeName;

// Requires 2 keys per font entry. The first key's name doesn't matter, but the size key must be suffixed with "Size"
// ie: @{ @"labelFont" : @"Helvetica", @"labelFontSize" : @15 }
- (UIFont *)fontForKey:(NSString*)key;

// Return a UIColor from a hex color stored in theme file
- (UIColor *)colorForKey:(NSString *)key;

// Return a UIImage for an image name stored in theme file
- (UIImage *)imageForKey:(NSString *)key;

// Change the theme name, should not include .plist extension
- (void)changeTheme:(NSString *)themeName;

@end
