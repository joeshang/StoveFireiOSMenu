//
//  RNThemedImageView.h
//  DT
//
//  Created by Ryan Nystrom on 2/5/13.
//
//

#import <UIKit/UIKit.h>
#import "RNThemeUpdateProtocol.h"

@interface RNThemedImageView : UIImageView
<RNThemeUpdateProtocol>

@property (strong, nonatomic) NSString *imageKey;

@end
