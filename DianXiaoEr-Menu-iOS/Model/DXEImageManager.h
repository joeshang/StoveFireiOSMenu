//
//  DXEImageManager.h
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 9/3/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DXEImageManager : NSObject

+ (DXEImageManager *)sharedInstance;

- (void)updateImageWithKeys:(NSMutableArray *)newImageKeys;
- (UIImage *)imageForKey:(NSString *)imageKey;
- (BOOL)saveChanges;

@end
