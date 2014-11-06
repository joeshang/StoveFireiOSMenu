//
//  CRModal.m
//  CRModal
//
//  Created by Joe Shang on 8/30/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "CRModal.h"
#import "UIImage+Blur.h"

#define kCRModalAlphaShow               1.0
#define kCRModalAlphaDismiss            0.0
#define kCRModalAnimationDuration       0.3
#define kCRModalBlurValue               0.3
#define kCRModalDarkAlphaValue          0.8

@interface CRModal ()

@property (nonatomic, strong) void(^completion)();

@property (nonatomic, strong) UIView *popupView;
@property (nonatomic, strong) UIView *coverView;
@property (nonatomic, strong) UIImageView *blurView;
@property (nonatomic, strong) UIViewController *originRootViewController;

@property (nonatomic, assign) CGAffineTransform popupOriginTransform;

@end

@implementation CRModal

#pragma mark - init

- (id)init
{
    self = [super init];
    
    if (self)
    {
        
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
}

#pragma mark - show & dismiss

+ (void)showModalView:(UIView *)modalView
          coverOption:(CRModalCoverOptions)coverOption
  tapOutsideToDismiss:(BOOL)tapOutsideToDismiss
             animated:(BOOL)animated
           completion:(void(^)())completion
{
    CRModal *modal = [[CRModal alloc] init];
    [modal showModalView:modalView
             coverOption:coverOption
     tapOutsideToDismiss:tapOutsideToDismiss
                animated:animated
              completion:completion];
}

+ (void)showModalView:(UIView *)modalView
{
    [self showModalView:modalView
            coverOption:CRModalOptionCoverDark
    tapOutsideToDismiss:YES
               animated:YES
             completion:nil];
}

+ (void)dismiss
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    if ([window.rootViewController isKindOfClass:[CRModal class]])
    {
        CRModal *modal = (CRModal *)window.rootViewController;
        [modal dismiss];
        modal = nil;
    }
}

- (void)showModalView:(UIView *)modalView
          coverOption:(CRModalCoverOptions)coverOption
  tapOutsideToDismiss:(BOOL)tapOutsideToDismiss
             animated:(BOOL)animated
           completion:(void(^)())completion
{
    self.completion = completion;
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    self.originRootViewController = window.rootViewController;
    self.view.transform = self.originRootViewController.view.transform;
    self.originRootViewController.view.transform = CGAffineTransformIdentity;
    CGRect frame = self.originRootViewController.view.frame;
    frame.origin = CGPointZero;
    self.originRootViewController.view.frame = frame;
    [self.view addSubview:self.originRootViewController.view];
    window.rootViewController = self;
    
    if (coverOption == CRModalOptionCoverBlur || coverOption == CRModalOptionCoverDarkBlur)
    {
        UIImage *image = [self screenShotForView:self.originRootViewController.view];
        image = [image boxblurImageWithBlur:kCRModalBlurValue];
        self.blurView = [[UIImageView alloc] initWithImage:image];
        self.blurView.alpha = kCRModalAlphaDismiss;
        self.blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:self.blurView];
    }
    
    self.coverView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.coverView.alpha = kCRModalAlphaDismiss;
    self.coverView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    if (coverOption == CRModalOptionCoverBlur)
    {
        self.coverView.backgroundColor = [UIColor clearColor];
    }
    else
    {
        self.coverView.backgroundColor = [UIColor colorWithRed:0/255.0
                                                         green:0/255.0
                                                          blue:0/255.0
                                                         alpha:kCRModalDarkAlphaValue];
    }
    [self.view addSubview:self.coverView];
    
    if (tapOutsideToDismiss)
    {
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                               action:@selector(onTapOutside:)];
        tapGestureRecognizer.delegate = self;
        [self.coverView addGestureRecognizer:tapGestureRecognizer];
    }
    
    self.popupView = [[UIView alloc] initWithFrame:modalView.bounds];
    self.popupView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin
                                    | UIViewAutoresizingFlexibleBottomMargin
                                    | UIViewAutoresizingFlexibleLeftMargin
                                    | UIViewAutoresizingFlexibleRightMargin;
    self.popupView.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2);
    [self.popupView addSubview:modalView];
    [self.coverView addSubview:self.popupView];
    
    [UIView animateWithDuration:kCRModalAnimationDuration animations:^{
        self.coverView.alpha = kCRModalAlphaShow;
        if (self.blurView)
        {
            self.blurView.alpha = kCRModalAlphaShow;
        }
    }];
    
    if (animated)
    {
        self.popupView.transform = CGAffineTransformMakeScale(0.8, 0.8);
        self.popupOriginTransform = self.popupView.transform;
        [UIView animateWithDuration:kCRModalAnimationDuration animations:^{
            self.popupView.transform = CGAffineTransformIdentity;
        }];
    }
    else
    {
        self.popupOriginTransform = self.popupView.transform;
    }
}

- (void)dismiss
{
    [UIView animateWithDuration:kCRModalAnimationDuration
                     animations:^{
                         self.coverView.alpha = kCRModalAlphaDismiss;
                         if (self.blurView)
                         {
                             self.blurView.alpha = kCRModalAlphaDismiss;
                         }
                         self.popupView.transform = self.popupOriginTransform;
                     }
                     completion:^(BOOL finished){
                         UIWindow *window =[[UIApplication sharedApplication] keyWindow];
                         [self.originRootViewController.view removeFromSuperview];
                         self.originRootViewController.view.transform = window.rootViewController.view.transform;
                         window.rootViewController = self.originRootViewController;
                         
                         if (self.completion)
                         {
                             self.completion();
                         }
                     }];
}

#pragma mark - action

- (void)onTapOutside:(id)sender
{
    [self dismiss];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    self.originRootViewController.view.transform = CGAffineTransformIdentity;
    self.originRootViewController.view.bounds = self.view.bounds;
    if(self.blurView != nil)
    {
        self.blurView.hidden = YES;
        UIImage *image = [self screenShotForView:self.originRootViewController.view];
        self.blurView.hidden = NO;
        self.blurView.image = [image boxblurImageWithBlur:kCRModalBlurValue];
    }
}

- (UIImage *)screenShotForView:(UIView *)view
{
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData *imageData = UIImageJPEGRepresentation(image, 1);
    image = [UIImage imageWithData:imageData];
    
    return image;
}

#pragma mark - gesture recognizer delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (touch.view == self.coverView)
    {
        return YES;
    }
    
    return NO;
}

@end
