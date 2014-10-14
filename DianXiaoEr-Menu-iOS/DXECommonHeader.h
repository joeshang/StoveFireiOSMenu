//
//  DXECommonHeader.h
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 8/3/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#ifndef DianXiaoEr_Menu_iOS_DXECommonHeader_h
#define DianXiaoEr_Menu_iOS_DXECommonHeader_h

#define kDXENavigationBarHeight                     94
#define kDXETabBarHeight                            71

#define kDXEScrollMenuHeight                        53
#define kDXEScrollMenuButtonPadding                 18
#define kDXEScrollMenuIndicatorHeight               2
#define kDXEScrollMenuTitleFontSize                 20
#define kDXEScrollMenuSubtitleFontSize              9

#define kDXECommonCornerRadius                      5
#define kDXECommonBorderWidth                       1

typedef NS_ENUM(NSUInteger, DXEDishProgress)
{
    DXEDishProgressTodo,
    DXEDishProgressDoing,
    DXEDishProgressDone
};

#define kDXEDidFinishLoadingNotification            @"DXEDidFinishLoadingNotification"
#define kDXEDidLoadingProgressNotification          @"DXEDidLoadingProgressNotification"
#define kDXEDidMoveToHomepageNotification           @"DXEDidMoveToHomePageNotification"
#define kDXEDidUpdateOrderProgressNotification      @"DXEDidUpdateOrderProgressNotification"

#define kDXEWebServiceBaseURL                       @"http://192.168.1.2/webservice.asmx"
#define kDXEImageBaseURL                            @"http://192.168.1.2/Images/"

#endif
