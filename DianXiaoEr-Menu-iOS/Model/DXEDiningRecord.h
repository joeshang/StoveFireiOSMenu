//
//  DXEDiningRecord.h
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 9/23/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DXEDiningRecord : NSObject

@property (nonatomic, strong) NSString *date;
@property (nonatomic, strong) NSNumber *dishCount;
@property (nonatomic, strong) NSNumber *totalPrice;
@property (nonatomic, strong) NSArray *dishes;

@end
