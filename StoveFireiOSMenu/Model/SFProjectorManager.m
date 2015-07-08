//
//  SFProjectorManager.m
//  StoveFireiOSMenu
//
//  Created by Joe Shang on 11/14/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "SFProjectorManager.h"
#import "GCDAsyncSocket.h"
#import "SVProgressHUD.h"

@interface SFProjectorManager () < GCDAsyncSocketDelegate >

@property (nonatomic, strong) GCDAsyncSocket *socket;

@end

@implementation SFProjectorManager

+ (SFProjectorManager *) sharedInstance
{
    
    static SFProjectorManager *sharedInstace = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstace = [[self alloc] init];
    });
    
    return sharedInstace;
}

- (void)connectToHost:(NSString *)host
{
#ifdef SF_3D_PROJECTOR
    self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    NSError *error = nil;
    [self.socket connectToHost:host
                        onPort:kSFProjectorPort
                         error:&error];
    if (error)
    {
        [SVProgressHUD showErrorWithStatus:@"连接立体投影仪失败"];
        NSLog(@"%@", error);
    }
#endif
}

- (void)doAction:(SFProjectorAction)action
        withName:(NSString *)name
{
#ifdef SF_3D_PROJECTOR
    if (self.socket && self.socket.isConnected)
    {
        NSDictionary *info = @{
                               @"dish": name,
                               @"action": [NSString stringWithFormat:@"%ld", action],
                               @"ticks": [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970]]
                               };
        NSData *data = [NSJSONSerialization dataWithJSONObject:info
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
        [self.socket writeData:data withTimeout:-1 tag:0];
    }
#endif
}

#pragma mark - AsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kSFDidConnectToProjectorNotification object:self];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    [SVProgressHUD showErrorWithStatus:@"连接立体投影仪失败"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSFDidDisconnectToProjectorNotification object:self];
}

@end
