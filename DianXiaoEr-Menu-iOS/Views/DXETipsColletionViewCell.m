//
//  DXETipsColletionViewCell.m
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 8/3/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "DXETipsColletionViewCell.h"

@implementation DXETipsColletionViewCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        self.layer.cornerRadius = kDXECollectionViewCellRadius;
        self.layer.masksToBounds = YES;
        self.layer.borderWidth = kDXECollectionViewCellBorderWidth;
        self.layer.borderColor = [[UIColor blueColor] CGColor];
    }
    
    return self;
}

@end
