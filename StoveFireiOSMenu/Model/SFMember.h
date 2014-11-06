//
//  SFUserDataManager.h
//  StoveFireiOSMenu
//
//  Created by Joe Shang on 9/22/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFMember : NSObject

@property (nonatomic, strong) NSNumber *memberid;
@property (nonatomic, strong) NSString *memberName;
@property (nonatomic, strong) NSString *memberPhone;
@property (nonatomic, strong) NSNumber *memberAccount;

@property (nonatomic, strong) NSArray *records;

@end
