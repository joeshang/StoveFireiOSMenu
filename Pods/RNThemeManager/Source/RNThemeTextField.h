//
//  RNThemeTextField.h
//  DT
//
//  Created by Ryan Nystrom on 2/5/13.
//
//

#import <UIKit/UIKit.h>
#import "RNThemeUpdateProtocol.h"

@interface RNThemeTextField : UITextField
<RNThemeUpdateProtocol>

@property (nonatomic, strong) NSString *fontKey;
@property (nonatomic, strong) NSString *textColorKey;

@end
