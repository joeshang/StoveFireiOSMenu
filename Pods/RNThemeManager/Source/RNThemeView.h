//
//  RNThemeView.h
//  DT
//
//  Created by Ryan Nystrom on 2/5/13.
//
//

#import <UIKit/UIKit.h>
#import "RNThemeUpdateProtocol.h"

@interface RNThemeView : UIView
<RNThemeUpdateProtocol>

@property (nonatomic, strong) NSString *backgroundColorKey;

@end
