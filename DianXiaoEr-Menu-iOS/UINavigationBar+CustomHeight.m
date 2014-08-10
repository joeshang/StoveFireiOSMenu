//
//  UINavigationBar+CustomHeight.m
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 8/8/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "UINavigationBar+CustomHeight.h"

@implementation UINavigationBar (CustomHeight)

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize newSize = CGSizeMake(self.bounds.size.width, kDXENavigationBarHeight);
    
    return newSize;
}

@end
