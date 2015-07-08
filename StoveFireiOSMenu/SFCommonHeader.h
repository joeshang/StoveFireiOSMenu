//
//  SFCommonHeader.h
//  StoveFireiOSMenu
//
//  Created by Joe Shang on 8/3/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#ifndef StoveFireiOSMenu_SFCommonHeader_h
#define StoveFireiOSMenu_SFCommonHeader_h

#define SF_UI_TEST
//#define SF_3D_PROJECTOR

#define kSFNavigationBarHeight                     94
#define kSFTabBarHeight                            71

#define kSFScrollMenuHeight                        53
#define kSFScrollMenuButtonPadding                 18
#define kSFScrollMenuIndicatorHeight               2
#define kSFScrollMenuTitleFontSize                 20
#define kSFScrollMenuSubtitleFontSize              9

#define kSFCommonCornerRadius                      5
#define kSFCommonBorderWidth                       1

typedef NS_ENUM(NSUInteger, SFDishProgress)
{
    SFDishProgressTodo,
    SFDishProgressDoing,
    SFDishProgressDone
};

#define kSFDidFinishLoadingNotification            @"SFDidFinishLoadingNotification"
#define kSFDidLoadingProgressNotification          @"SFDidLoadingProgressNotification"
#define kSFDidMoveToHomepageNotification           @"SFDidMoveToHomePageNotification"
#define kSFDidUpdateOrderProgressNotification      @"SFDidUpdateOrderProgressNotification"
#define kSFDidConnectToProjectorNotification       @"SFDidConnectToProjectorNotification"
#define kSFDidDisconnectToProjectorNotification    @"SFDidDisconnectToProjectorNotification"

#define kSFWebServiceBaseURL                       @"http://192.168.1.2/webservice.asmx"
#define kSFImageBaseURL                            @"http://192.168.1.2/Images/"
#define kSFQuestionnaireBaseURL                    @"http://192.168.1.2:8080"
#define kSFProjectorPort                           51112


#endif
