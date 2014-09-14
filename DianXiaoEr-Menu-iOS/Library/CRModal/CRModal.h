//
//  CRModal.h
//  CRModal
//
//  Created by Joe Shang on 8/30/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, CRModalCoverOptions)
{
    CRModalOptionCoverDark,
    CRModalOptionCoverBlur,
    CRModalOptionCoverDarkBlur
};

@interface CRModal : UIViewController <UIGestureRecognizerDelegate>

+ (void)showModalView:(UIView *)modalView
          coverOption:(CRModalCoverOptions)coverOption
  tapOutsideToDismiss:(BOOL)tapOutsideToDismiss
             animated:(BOOL)animated
           completion:(void(^)())completion;

+ (void)showModalView:(UIView *)modalView;

+ (void)dismiss;

@end
