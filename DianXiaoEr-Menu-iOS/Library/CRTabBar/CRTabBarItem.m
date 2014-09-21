//
//  CRTabBarItem.m
//  CRTabBar
//
//  Created by Joe Shang on 9/21/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "CRTabBarItem.h"

#define kCRTabBarItemBadgeTextPadding       2.0

@interface CRTabBarItem ()

@property (nonatomic, strong) UIImage *normalImage;
@property (nonatomic, strong) UIImage *selectedImage;
@property (nonatomic, strong) UIImage *normalBackgroundImage;
@property (nonatomic, strong) UIImage *selectedBackgroundImage;

@end

@implementation CRTabBarItem

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self commonSetup];
    }
    return self;
}

- (id)initWithTitle:(NSString *)title
        normalImage:(UIImage *)normalImage
      selectedImage:(UIImage *)selectedImage
{
    self = [self initWithFrame:CGRectZero];
    
    if (title)
    {
        _title = title;
    }
    
    _normalImage = normalImage;
    _selectedImage = selectedImage;
    
    return self;
}

- (void)commonSetup
{
    [self setBackgroundColor:[UIColor clearColor]];
    
    _title = @"";
    _titlePositionAdjustment = UIOffsetZero;
    _normalTitleAttributes = @{
                               NSFontAttributeName: [UIFont systemFontOfSize:12],
                               NSForegroundColorAttributeName: [UIColor blackColor]
                               };
    _selectedTitleAttributes = [_normalTitleAttributes copy];
    
    _badgeBackgroundColor = [UIColor redColor];
    _badgeBackgroundImage = nil;
    _badgeTextFont = [UIFont systemFontOfSize:12];
    _badgeTextColor = [UIColor whiteColor];
    _badgePositionAdjustment = UIOffsetZero;
}

- (void)setNormalImage:(UIImage *)normalImage withSelectedImage:(UIImage *)selectedImage
{
    if (normalImage && normalImage != self.normalImage)
    {
        self.normalImage = normalImage;
    }
    
    if (selectedImage && selectedImage != self.selectedImage)
    {
        self.selectedImage = selectedImage;
    }
}

- (void)setNormalBackgroundImage:(UIImage *)normalBackgroundImage
     withSelectedBackgroundImage:(UIImage *)selectedBackgroundImage;
{
    if (normalBackgroundImage && normalBackgroundImage != self.normalBackgroundImage)
    {
        self.normalBackgroundImage = normalBackgroundImage;
    }
    
    if (selectedBackgroundImage && selectedBackgroundImage != self.selectedBackgroundImage)
    {
        self.selectedBackgroundImage = selectedBackgroundImage;
    }
}

- (void)setBadgeValue:(NSString *)badgeValue
{
    _badgeValue = badgeValue;
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGSize frameSize = self.bounds.size;
    UIImage *image = nil;
    UIImage *backgroundImage = nil;
    NSDictionary *titleAttributes = nil;
    
    if (self.isSelected)
    {
        image = self.selectedImage;
        backgroundImage = self.selectedBackgroundImage;
        titleAttributes = self.selectedTitleAttributes;
    }
    else
    {
        image = self.normalImage;
        backgroundImage = self.normalBackgroundImage;
        titleAttributes = self.normalTitleAttributes;
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    // draw background image
    [backgroundImage drawInRect:self.bounds];
    
    // draw image & title
    CGSize imageSize = [image size];
    CGFloat imageStartingY = 0.0f;
    if ([self.title length] != 0)
    {
        CGSize titleSize = [self.title sizeWithAttributes:titleAttributes];
        imageStartingY = roundf((frameSize.height - imageSize.height - titleSize.height) / 2);
        [image drawInRect:CGRectMake(roundf(frameSize.width / 2 - imageSize.width / 2) + self.imagePositionAdjustment.horizontal,
                                     imageStartingY + self.imagePositionAdjustment.vertical,
                                     imageSize.width,
                                     imageSize.height)];
        
        [self.title drawInRect:CGRectMake(roundf(frameSize.width /2 - titleSize.width / 2) + self.titlePositionAdjustment.horizontal,
                                          imageStartingY + imageSize.height + self.titlePositionAdjustment.vertical,
                                          titleSize.width,
                                          titleSize.height)
                withAttributes:titleAttributes];
    }
    else
    {
        imageStartingY = roundf(frameSize.height / 2 - imageSize.height / 2);
        [image drawInRect:CGRectMake(roundf(frameSize.width / 2 - imageSize.width / 2 ) + self.imagePositionAdjustment.horizontal,
                                     imageStartingY + self.imagePositionAdjustment.vertical,
                                     imageSize.width,
                                     imageSize.height)];
    }
    
    // draw badge
    if ([self.badgeValue length] != 0)
    {
        NSMutableParagraphStyle *badgeTextStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        badgeTextStyle.lineBreakMode = NSLineBreakByWordWrapping;
        badgeTextStyle.alignment = NSTextAlignmentCenter;
        NSDictionary *badgeTextAttributes = @{
                                              NSFontAttributeName: self.badgeTextFont,
                                              NSForegroundColorAttributeName: self.badgeTextColor,
                                              NSParagraphStyleAttributeName: badgeTextStyle
                                              };
        CGSize badgeSize = [self.badgeValue sizeWithAttributes:badgeTextAttributes];
        if (badgeSize.width < badgeSize.height)
        {
            badgeSize = CGSizeMake(badgeSize.height, badgeSize.height);
        }
        
        // calculate background frame
        CGFloat textOffset = kCRTabBarItemBadgeTextPadding;
        CGFloat badgeStartingX = roundf(frameSize.width / 2 + imageSize.width / 2 - badgeSize.width / 2 - textOffset);
        CGFloat badgeStartingY = roundf(imageStartingY - badgeSize.height / 2 - textOffset);
        CGRect badgeBackgroundFrame = CGRectMake(badgeStartingX + self.badgePositionAdjustment.horizontal,
                                                 badgeStartingY + self.badgePositionAdjustment.vertical,
                                                 badgeSize.width + 2 * textOffset,
                                                 badgeSize.height + 2 * textOffset);
        
        // draw badge background
        if (self.badgeBackgroundImage)
        {
            [self.badgeBackgroundImage drawInRect:badgeBackgroundFrame];
        }
        else if (self.badgeBackgroundColor)
        {
            CGContextSetFillColorWithColor(context, [self.badgeBackgroundColor CGColor]);
            CGContextFillEllipseInRect(context, badgeBackgroundFrame);
        }
        
        // draw badge value
        [self.badgeValue drawInRect:CGRectMake(CGRectGetMinX(badgeBackgroundFrame) + textOffset,
                                               CGRectGetMinY(badgeBackgroundFrame) + textOffset,
                                               badgeSize.width,
                                               badgeSize.height)
                     withAttributes:badgeTextAttributes];
    }
    
    CGContextRestoreGState(context);
}

@end
