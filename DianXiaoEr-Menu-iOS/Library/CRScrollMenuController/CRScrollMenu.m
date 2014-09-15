//
//  CRScrollMenu.m
//  CRScrollMenu
//
//  Created by Joe Shang on 8/20/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "CRScrollMenu.h"
#import "CRScrollMenuButton.h"

#define kCRScrollMenuScrollAnimationTime            0.2
#define kCRScrollMenuIndicatorMargin                5.0
#define kCRScrollMenuDefaultButtonPadding           8.0
#define kCRScrollMenuDefaultIndicatorHeight         4.0
#define kCRScrollMenuDefaultIndicatorColor          [UIColor redColor]

@interface CRScrollMenu()

@property (nonatomic, strong) UIScrollView *contentView;
@property (nonatomic, strong) UIView *indicatorView;
@property (nonatomic, strong) NSMutableArray *buttons;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, assign) NSUInteger currentIndex;

@end

@implementation CRScrollMenu

#pragma mark - life cycle

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

- (void)commonSetup
{
    _currentIndex = 0;
    _buttons = [[NSMutableArray alloc] init];

    _buttonPadding = kCRScrollMenuDefaultButtonPadding;
    _indicatorColor = kCRScrollMenuDefaultIndicatorColor;
    _indicatorHeight = kCRScrollMenuDefaultIndicatorHeight;
    
    _contentView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _contentView.showsHorizontalScrollIndicator = NO;
    _contentView.backgroundColor = [UIColor clearColor];
    [self addSubview:_contentView];
    
    _indicatorView = [[UIView alloc] init];
    _indicatorView.backgroundColor = kCRScrollMenuDefaultIndicatorColor;
    _indicatorView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [_contentView addSubview:_indicatorView];
}

#pragma mark - view related

- (void)layoutSubviews
{
    CGFloat x = 0.0;
    
    for (CRScrollMenuButton *button in self.buttons)
    {
        CGRect rect = button.frame;
        rect.origin.x = x;
        rect.origin.y = 0.0;
        rect.size.height = self.bounds.size.height;
        button.frame = rect;
        
        x += rect.size.width;
    }

    [self setIndicatorAtIndex:self.currentIndex];
    self.contentView.contentSize = CGSizeMake(x, CGRectGetHeight(self.bounds));
}

- (void)setIndicatorAtIndex:(NSUInteger)index
{
    if ([self.buttons count] == 0)
    {
        self.indicatorView.frame = CGRectZero;
    }
    else
    {
        // 设置indicator的frame
        CGRect rect = [[self.buttons objectAtIndex:index] frame];
        CGRect indicatorRect = CGRectMake(rect.origin.x + self.buttonPadding - kCRScrollMenuIndicatorMargin,
                                          rect.origin.y + rect.size.height - self.indicatorHeight,
                                          rect.size.width - (self.buttonPadding - kCRScrollMenuIndicatorMargin) * 2,
                                          self.indicatorHeight);
        self.indicatorView.frame = indicatorRect;
        
        // index对应的button设置为selected
        [[self.buttons objectAtIndex:index] setSelected:YES];
    }
}

- (void)moveItemFromIndex:(NSUInteger)oldIndex toIndex:(NSUInteger)newIndex
{
    [[self.buttons objectAtIndex:oldIndex] setSelected:NO];
    [self setIndicatorAtIndex:newIndex];
}

#pragma mark - action

- (void)scrollToIndex:(NSUInteger)index
{
    CGRect rect = [[self.buttons objectAtIndex:index] frame];
    
    CGPoint contentOffset = self.contentView.contentOffset;
    if (CGRectGetMinX(rect) < contentOffset.x)
    {
        contentOffset.x = CGRectGetMinX(rect);
    }
    else if (CGRectGetMaxX(rect) > contentOffset.x + self.bounds.size.width)
    {
        contentOffset.x += CGRectGetMaxX(rect) - contentOffset.x - self.bounds.size.width;
    }
    [UIView animateWithDuration:kCRScrollMenuScrollAnimationTime animations:^{
        self.contentView.contentOffset = contentOffset;
    }];
    
    [UIView animateWithDuration:kCRScrollMenuScrollAnimationTime animations:^{
        [self moveItemFromIndex:self.currentIndex toIndex:index];
    }];
    
    self.currentIndex = index;
}

- (void)onItemViewClicked:(id)sender
{
    NSUInteger index = [self.buttons indexOfObjectIdenticalTo:sender];
    
    [self scrollToIndex:index];
    
    if (self.delegate
        && [self.delegate respondsToSelector:@selector(scrollMenu:didSelectedAtIndex:)])
    {
        [self.delegate scrollMenu:self didSelectedAtIndex:index];
    }
}

#pragma mark - object management

- (void)setButtonsByItems:(NSArray *)items
{
    if (items == nil || [items count] == 0)
    {
        return;
    }
    
    if ([self.buttons count] != 0)
    {
        for (CRScrollMenuButton *button in self.buttons)
        {
            [button removeFromSuperview];
        }
        [self.buttons removeAllObjects];
    }
    
    for (CRScrollMenuItem *item in items)
    {
        CRScrollMenuButton *button = [self buttonByItem:item];
        [self.buttons addObject:button];
    }
    
    self.currentIndex = 0;
    
    [self layoutSubviews];
}

- (void)insertButtonByItem:(CRScrollMenuItem *)item atIndex:(NSUInteger)index
{
    CRScrollMenuButton *button = [self buttonByItem:item];
    
    if ([self.buttons count] == 0)
    {
        [self.buttons addObject:button];
    }
    else
    {
        CGPoint contentOffset = self.contentView.contentOffset;
        if (index <= self.currentIndex)
        {
            contentOffset.x += button.frame.size.width;
            self.contentView.contentOffset = contentOffset;
        }
        
        CRScrollMenuButton *currentIndexButton = [self.buttons objectAtIndex:self.currentIndex];
        [self.buttons insertObject:button atIndex:index];
        self.currentIndex = [self.buttons indexOfObjectIdenticalTo:currentIndexButton];
        
    }
    
    [self layoutSubviews];
}

- (void)removeButtonAtIndex:(NSUInteger)index
{
    if ([self.buttons count] == 0)
    {
        return;
    }
    
    [[self.buttons objectAtIndex:index] removeFromSuperview];
    
    CGPoint contentOffset = self.contentView.contentOffset;
    float removedButtonWidth = [[self.buttons objectAtIndex:index] frame].size.width;
    
    CRScrollMenuButton *currentIndexButton = [self.buttons objectAtIndex:self.currentIndex];
    [self.buttons removeObjectAtIndex:index];
    if (index == self.currentIndex) // 若删除的项是当前选择项，则回到第一项
    {
        self.currentIndex = 0;
        
        contentOffset.x = 0;
        self.contentView.contentOffset = contentOffset;
    }
    else
    {
        if (index < self.currentIndex)
        {
            contentOffset.x -= removedButtonWidth;
            self.contentView.contentOffset = contentOffset;
        }
        
        // 更新currentIndex
        self.currentIndex = [self.buttons indexOfObjectIdenticalTo:currentIndexButton];
    }
    
    [self layoutSubviews];
}

- (CRScrollMenuButton *)buttonByItem:(CRScrollMenuItem *)item
{
    CGSize titleSize = [item.title sizeWithAttributes:self.normalTitleAttributes];
    CRScrollMenuButton *button = [[CRScrollMenuButton alloc] initWithFrame:CGRectMake(0,
                                                                                      0,
                                                                                      titleSize.width + 2 * self.buttonPadding,
                                                                                      titleSize.height)];
    button.title = item.title;
    button.subtitle = item.subtitle;
    if (self.buttonTitleSpacing)
    {
        button.titleSpacing = self.buttonTitleSpacing;
    }
    if (self.normalTitleAttributes)
    {
        button.normalTitleAttributes = self.normalTitleAttributes;
    }
    if (self.selectedTitleAttributes)
    {
        button.selectedTitleAttributes = self.selectedTitleAttributes;
    }
    if (self.normalSubtitleAttributes)
    {
        button.normalSubtitleAttributes = self.normalSubtitleAttributes;
    }
    if (self.selectedSubtitleAttributes)
    {
        button.selectedSubtitleAttributes = self.selectedSubtitleAttributes;
    }
    button.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [button addTarget:self
               action:@selector(onItemViewClicked:)
     forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:button];
    
    return button;
}

#pragma mark - overwritten setters

- (void)setIndicatorHeight:(NSUInteger)indicatorHeight
{
    CGRect rect = self.indicatorView.frame;
    rect.origin.y = CGRectGetHeight(self.bounds) - indicatorHeight;
    rect.size.height = indicatorHeight;
    self.indicatorView.frame = rect;
    
    _indicatorHeight = indicatorHeight;
}

- (void)setIndicatorColor:(UIColor *)indicatorColor
{
    self.indicatorView.backgroundColor = indicatorColor;
    _indicatorColor = indicatorColor;
}

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    if (_backgroundImageView == nil)
    {
        _backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self insertSubview:_backgroundImageView belowSubview:self.contentView];
    }
    
    _backgroundImage = backgroundImage;
    _backgroundImageView.image = backgroundImage;
}

@end
