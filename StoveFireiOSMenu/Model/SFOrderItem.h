//
//  SFOrderItem.h
//  StoveFireiOSMenu
//
//  Created by Joe Shang on 10/16/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFOrderItem : NSObject

@property (nonatomic, strong) NSNumber *itemid;
@property (nonatomic, strong) NSNumber *count;
@property (nonatomic, strong) NSNumber *tradeid;
@property (nonatomic, strong) NSNumber *progress;

- (id)initWithItemid:(NSNumber *)itemid;

@end
