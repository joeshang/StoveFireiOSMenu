//
//  CRTabBar.m
//  CRTabBar
//
//  Created by Joe Shang on 9/21/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "CRTabBar.h"
#import "CRTabBarItem.h"

@interface CRTabBar ()
{
    NSInteger _selectedIndex;
}

@property (nonatomic, strong) UIImageView *backgroundImageView;

@end

@implementation CRTabBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self commonSetup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self commonSetup];
    }
    return self;
}

- (id)init
{
    return [self initWithFrame:CGRectZero];
}

- (void)commonSetup
{
    _selectedIndex = 0;
    _contentEdgeInsets = UIEdgeInsetsZero;
}

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    if (self.backgroundImageView == nil)
    {
        self.backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:self.backgroundImageView];
    }
    
    self.backgroundImageView.image = backgroundImage;
}

- (void)setHeight:(CGFloat)height
{
    CGRect newRect = self.frame;
    newRect.size.height = height;
    self.frame = newRect;
}

- (void)setItems:(NSArray *)items
{
    for (CRTabBarItem *item in _items)
    {
        [item removeFromSuperview];
    }
    
    _items = [items copy];
    for (CRTabBarItem *item in _items)
    {
        [item addTarget:self
                 action:@selector(onTabBarItemSelected:)
       forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:item];
    }
    
    _selectedIndex = 0;
    [[items objectAtIndex:_selectedIndex] setSelected:YES];
}

- (void)setItemSelectedAtIndex:(NSInteger)selectedIndex
{
    if (_selectedIndex == selectedIndex)
    {
        return;
    }
    
    [[self.items objectAtIndex:_selectedIndex] setSelected:NO];
    _selectedIndex = selectedIndex;
    [[self.items objectAtIndex:_selectedIndex] setSelected:YES];
}

- (NSInteger)selectedIndex
{
    return _selectedIndex;
}

- (void)layoutSubviews
{
    self.backgroundImageView.frame = self.bounds;
    
    CGFloat itemWidth = roundf((self.bounds.size.width - self.contentEdgeInsets.left - self.contentEdgeInsets.right) / [self.items count]);
    CGFloat itemHeight = self.bounds.size.height - self.contentEdgeInsets.top - self.contentEdgeInsets.bottom;
    [self.items enumerateObjectsUsingBlock:^(CRTabBarItem *item, NSUInteger index, BOOL *stop){
        item.frame = CGRectMake(self.contentEdgeInsets.left + index * itemWidth,
                                self.contentEdgeInsets.top,
                                itemWidth,
                                itemHeight);
        [item setNeedsDisplay];
    }];
}

- (void)onTabBarItemSelected:(id)sender
{
    NSInteger index = [self.items indexOfObject:sender];
    if ([self.delegate respondsToSelector:@selector(tabBar:shouldSelecteItemAtIndex:)])
    {
        if (![self.delegate tabBar:self shouldSelecteItemAtIndex:index])
        {
            return;
        }
    }

    [self setItemSelectedAtIndex:index];

    if ([self.delegate respondsToSelector:@selector(tabBar:didSelectItemAtIndex:)])
    {
        [self.delegate tabBar:self didSelectItemAtIndex:index];
    }
}

@end
