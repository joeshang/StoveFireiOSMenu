//
//  SFQRCodeViewController.m
//  StoveFireiOSMenu
//
//  Created by Joe Shang on 9/30/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "SFQRCodeViewController.h"

#define kSFQRCodeScanningLineAnimationTime     2
#define kSFQRCodeScanningLineScanDistance      352

@interface SFQRCodeViewController ()

@end

@implementation SFQRCodeViewController

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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setupCamera];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self startScanningLine];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)startScanningLine
{
    CGPoint center = self.scanningLine.center;
    center.y += kSFQRCodeScanningLineScanDistance;
    
    [UIView animateWithDuration:kSFQRCodeScanningLineAnimationTime
                          delay:0.0
                        options:UIViewAnimationOptionRepeat
                     animations:^{
                         self.scanningLine.center = center;
                     }
                     completion:nil];
}

- (void)setupCamera
{
    // Device
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Input
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // Output
    self.output = [[AVCaptureMetadataOutput alloc] init];
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // Session
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPresetHigh;
    if ([self.session canAddInput:self.input])
    {
        [self.session addInput:self.input];
    }
    if ([self.session canAddOutput:self.output])
    {
        [self.session addOutput:self.output];
    }
    
    self.output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    
    // Preview
    self.preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.preview.frame = self.scanningBox.frame;
    [self.view.layer insertSublayer:self.preview below:self.scanningBox.layer];
    
    [self.session startRunning];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate

-    (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputMetadataObjects:(NSArray *)metadataObjects
          fromConnection:(AVCaptureConnection *)connection
{
    NSString *qrcode = nil;
    
    if ([metadataObjects count] > 0)
    {
        AVMetadataMachineReadableCodeObject *readableCodeObject = [metadataObjects firstObject];
        qrcode = readableCodeObject.stringValue;
        
        if ([self.delegate respondsToSelector:@selector(qrCodeDidScan:)])
        {
            [self.delegate qrCodeDidScan:qrcode];
        }
    }
    
    [self dismissViewControllerAnimated:NO completion:^{
        [self.session stopRunning];
    }];
}

- (IBAction)onReturnButtonClicked:(id)sender
{
    [self dismissViewControllerAnimated:NO completion:^{
        [self.session stopRunning];
    }];
}

@end
