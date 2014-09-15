//
//  CRScrollMenuButton.m
//  CRScrollMenu
//
//  Created by Joe Shang on 8/24/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "CRScrollMenuButton.h"

#define kCRScrollMenuDefaultTitleSpaing            0

@implementation CRScrollMenuButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        [self commonSetup];
    }
    
    return self;
}

- (void)commonSetup
{
    self.backgroundColor = [UIColor clearColor];
    
    _titleSpacing = kCRScrollMenuDefaultTitleSpaing;
    _normalTitleAttributes = @{
                               NSFontAttributeName: [UIFont systemFontOfSize:17],
                               NSForegroundColorAttributeName: [UIColor redColor]
                               };
    _normalSubtitleAttributes = @{
                                  NSFontAttributeName: [UIFont systemFontOfSize:12],
                                  NSForegroundColorAttributeName: [UIColor blueColor]
                                  };
    _selectedTitleAttributes = [_normalTitleAttributes copy];
    _selectedSubtitleAttributes = [_normalSubtitleAttributes copy];
}

- (void)drawRect:(CGRect)rect
{
    CGSize titleSize = CGSizeZero;
    CGSize subtitleSize = CGSizeZero;
    NSDictionary *titleAttributes = nil;
    NSDictionary *subtitleAttributes = nil;
    
    if (self.isSelected)
    {
        titleAttributes = self.selectedTitleAttributes;
        subtitleAttributes = self.selectedSubtitleAttributes;
    }
    else
    {
        titleAttributes = self.normalTitleAttributes;
        subtitleAttributes = self.normalSubtitleAttributes;
    }
    
    if (self.title && [self.title length])
    {
        titleSize = [self.title sizeWithAttributes:titleAttributes];
        
        if (self.subtitle && [self.subtitle length])
        {
            subtitleSize = [self.subtitle sizeWithAttributes:subtitleAttributes];
            float y = roundf((self.bounds.size.height - titleSize.height - subtitleSize.height - self.titleSpacing) / 2);
            [self.title drawInRect:CGRectMake(roundf((self.bounds.size.width - titleSize.width) / 2),
                                              y,
                                              titleSize.width,
                                              titleSize.height)
                    withAttributes:titleAttributes];
            [self.subtitle drawInRect:CGRectMake(roundf((self.bounds.size.width - subtitleSize.width) / 2),
                                                 y + titleSize.height + self.titleSpacing,
                                                 subtitleSize.width,
                                                 subtitleSize.height)
                       withAttributes:subtitleAttributes];
        }
        else
        {
            [self.title drawInRect:CGRectMake(roundf((self.bounds.size.width - titleSize.width) / 2),
                                              roundf((self.bounds.size.height - titleSize.height) / 2),
                                              titleSize.width,
                                              titleSize.height)
                    withAttributes:titleAttributes];
            
        }
    }
}

@end
