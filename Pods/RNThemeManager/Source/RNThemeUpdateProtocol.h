//
//  RNThemeUpdateProtocol.h
//  DT
//
//  Created by Ryan Nystrom on 2/5/13.
//
//

#import <Foundation/Foundation.h>

@protocol RNThemeUpdateProtocol <NSObject>

@required

// Call this method to apply a theme from the manager, call again when manager notifies that a theme has changed
- (void)applyTheme;

@end
