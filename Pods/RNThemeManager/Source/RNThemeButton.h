//
//  RNThemeButton.h
//  DT
//
//  Created by Ryan Nystrom on 2/5/13.
//
//

#import <UIKit/UIKit.h>
#import "RNThemeUpdateProtocol.h"

@interface RNThemeButton : UIButton
<RNThemeUpdateProtocol>

@property (nonatomic, strong) NSString *backgroundImageKey;
@property (nonatomic, strong) NSString *backgroundColorKey;
@property (nonatomic, strong) NSString *fontKey;
@property (nonatomic, strong) NSString *textColorKey;
@property (nonatomic, strong) NSString *highlightedTextColorKey;

@end
