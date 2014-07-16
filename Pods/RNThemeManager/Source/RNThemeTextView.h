//
//  RNThemeTextView.h
//  DT
//
//  Created by Ryan Nystrom on 2/5/13.
//
//

#import <UIKit/UIKit.h>
#import "RNThemeUpdateProtocol.h"

@interface RNThemeTextView : UITextView
<RNThemeUpdateProtocol>

@property (nonatomic, strong) NSString *fontKey;
@property (nonatomic, strong) NSString *textColorKey;

@end
