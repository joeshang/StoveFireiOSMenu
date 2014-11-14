//
//  SFProjectorManager.h
//  StoveFireiOSMenu
//
//  Created by Joe Shang on 11/14/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SFProjectorAction)
{
    SFProjectorActionStop,
    SFProjectorActionPlay
};

@interface SFProjectorManager : NSObject

+ (SFProjectorManager *)sharedInstance;

- (void)connectToHost:(NSString *)host;
- (void)doAction:(SFProjectorAction)action
        withName:(NSString *)name;

@end
