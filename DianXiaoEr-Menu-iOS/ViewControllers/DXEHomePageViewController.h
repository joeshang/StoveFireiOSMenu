//
//  DXEHomePageViewController.h
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 7/14/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHTCollectionViewWaterfallLayout.h"
#import "iCarousel.h"

@interface DXEHomePageViewController : UIViewController
<
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    CHTCollectionViewDelegateWaterfallLayout,
    iCarouselDataSource,
    iCarouselDelegate
>

@end
