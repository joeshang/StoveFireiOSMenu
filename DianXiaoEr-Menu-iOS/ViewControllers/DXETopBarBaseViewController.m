//
//  DXETopBarBaseViewController.m
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 9/16/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "DXETopBarBaseViewController.h"

#define kDXEQrCodeButtonOriginX         660
#define kDXEQrCodeButtonOriginY         25

@interface DXETopBarBaseViewController ()

@end

@implementation DXETopBarBaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.topBarBackgroundView = [[UIImageView alloc] init];
    self.topBarBackgroundView.contentMode = UIViewContentModeScaleToFill;
    self.topBarBackgroundView.image = [[RNThemeManager sharedManager] imageForName:@"navigationbar_background.png"];
    [self.view addSubview:self.topBarBackgroundView];
    
    UIImage *image = [UIImage imageNamed:@"qrcode_button"];
    CGSize imageSize = [image size];
    self.qrCodeButton = [[UIButton alloc] initWithFrame:CGRectMake(kDXEQrCodeButtonOriginX,
                                                                   kDXEQrCodeButtonOriginY,
                                                                   imageSize.width,
                                                                   imageSize.height)];
    [self.qrCodeButton setImage:image forState:UIControlStateNormal];
    [self.qrCodeButton addTarget:self
                          action:@selector(onQRcodeButtonClicked:)
                forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.qrCodeButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.topBarBackgroundView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), kDXENavigationBarHeight);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)onQRcodeButtonClicked:(id)sender
{
    
}

@end
