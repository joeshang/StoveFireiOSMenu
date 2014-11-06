//
//  SFImageManager.m
//  StoveFireiOSMenu
//
//  Created by Joe Shang on 9/3/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "SFImageManager.h"
#import "AFNetworking.h"

#define kSFImageKeysArchiveName        @"Imagekeys.archive"

@interface SFImageManager ()

@property (nonatomic, strong) NSMutableArray *cachedImageKeys;
@property (nonatomic, strong) NSMutableDictionary *recentlyImages;

@end

@implementation SFImageManager

#pragma mark - singleton init

+ (SFImageManager *)sharedInstance
{
    static SFImageManager *sharedManager = nil;
    
    if (sharedManager == nil)
    {
        sharedManager = [[super allocWithZone:nil] init];
    }
    
    return sharedManager;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    return [self sharedInstance];
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        NSString *path = [self archivePathForKey:kSFImageKeysArchiveName];
        _cachedImageKeys = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        if (_cachedImageKeys == nil)
        {
            _cachedImageKeys = [[NSMutableArray alloc] init];
        }
        
    }
    
    return self;
}

#pragma mark - getting image

// imageKey的命名格式为：class-id@time
//  * class：图片的种类，例如菜类图片的class为0，菜品图片的class为1
//  * id：图片的ID，是图片在本类中的唯一标示
//  * time：图片更新的时间，用来对比图片是否需要更新

- (UIImage *)imageForKey:(NSString *)imageKey
{
    if (!imageKey)
    {
        return nil;
    }
    
#ifdef SF_UI_TEST
    NSString *imageClass = [imageKey substringToIndex:1];
    UIImage *image;
    if ([imageClass isEqualToString:@"0"])
    {
        image = [UIImage imageNamed:@"default_dish_class"];
    }
    else if ([imageClass isEqualToString:@"1"])
    {
        image = [UIImage imageNamed:@"default_dish_item"];
    }
    else if ([imageClass isEqualToString:@"2"])
    {
        image = [UIImage imageNamed:@"default_dish_thumbnail"];
    }
    return image;
#else
    UIImage *result = [self.recentlyImages objectForKey:imageKey];
    if (!result)
    {
        result = [UIImage imageWithContentsOfFile:[self archivePathForKey:imageKey]];
        if (result)
        {
            [self.recentlyImages setObject:result forKey:imageKey];
        }
        else
        {
            for (NSString *key in self.cachedImageKeys)
            {
                if ([key isEqualToString:imageKey])
                {
                    [self.cachedImageKeys removeObject:key];
                    break;
                }
            }
            NSLog(@"Error: unable to find image %@", [self archivePathForKey:imageKey]);
        }
    }
    return result;
#endif
}

- (void)deleteImageForKey:(NSString *)imageKey
{
#ifdef SF_UI_TEST
    NSLog(@"delete image: %@", imageKey);
#else
    if (imageKey)
    {
        [self.recentlyImages removeObjectForKey:imageKey];
        NSString *imagePath = [self archivePathForKey:imageKey];
        [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
    }
#endif
}

- (void)updateImageWithKeys:(NSMutableArray *)newImageKeys
{
#ifdef SF_UI_TEST
#else
    if ([newImageKeys count] == 0)
    {
        return;
    }
    
    NSMutableArray *deprecatedImageKeys = [NSMutableArray arrayWithArray:self.cachedImageKeys];
    NSMutableArray *requestImageKeys = nil;
    if ([self.cachedImageKeys count] == 0)
    {
        // 本地无图片，因此要请求每一个newKey对应的图片
        requestImageKeys = [NSMutableArray arrayWithArray:newImageKeys];
    }
    else
    {
        requestImageKeys = [[NSMutableArray alloc] init];
        
        for (NSString *newKey in newImageKeys)
        {
            [self.cachedImageKeys enumerateObjectsUsingBlock:^(NSString *cachedKey, NSUInteger index, BOOL *stop){
                // 完全匹配说明图片无更新
                if ([newKey isEqualToString:cachedKey])
                {
                    *stop = YES;
                    [deprecatedImageKeys removeObject:cachedKey];
                }
                else
                {
                    NSString *newID = [[newKey componentsSeparatedByString:@"@"] objectAtIndex:0];
                    NSString *cachedID = [[cachedKey componentsSeparatedByString:@"@"] objectAtIndex:0];
                    // 图片id匹配说明是更新项，删除旧图片，请求新图片
                    if ([newID isEqualToString:cachedID])
                    {
                        *stop = YES;
                        // 由于没有从deprecatedImageKeys中移除，因此会在后面删除旧照片
                        [requestImageKeys addObject:newKey];
                    }
                    else
                    {
                        // newKey在cachedImageKeys没有匹配项，说明是新增项，请求图片
                        if ([cachedKey isEqualToString:[self.cachedImageKeys lastObject]])
                        {
                            [requestImageKeys addObject:newKey];
                        }
                    }
                }
            }];
        }
        
        // 对比完newImageKeys后在deprecatedImageKeys中还剩下的全是需要删除的图片
        if ([deprecatedImageKeys count] != 0)
        {
            for (NSString *cachedKey in deprecatedImageKeys)
            {
                [self.cachedImageKeys removeObject:cachedKey];
                [self deleteImageForKey:cachedKey];
            }
        }
    }
    
    // 向服务器请求图片
    if ([requestImageKeys count] != 0)
    {
        __block NSUInteger totalCount = [requestImageKeys count];
        __block NSUInteger progress = 0;
        for (NSString *imageKey in requestImageKeys)
        {
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kSFImageBaseURL, imageKey]];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            operation.responseSerializer = [AFImageResponseSerializer serializer];
            [operation setCompletionBlockWithSuccess: ^(AFHTTPRequestOperation *operation, id responseObject){
                progress++;
                UIImage *image = responseObject;
                NSData *imageData = UIImageJPEGRepresentation(image, 1);
                [imageData writeToFile:[self archivePathForKey:imageKey] atomically:YES];
                [self.cachedImageKeys addObject:imageKey];
                
                NSString *message = [NSString stringWithFormat:@"正在加载图片(进度:%lu/%lu)", progress, totalCount];
                NSDictionary *userInfo = @{ @"message": message };
                [[NSNotificationCenter defaultCenter] postNotificationName:kSFDidLoadingProgressNotification object:self userInfo:userInfo];
                
                if (progress == totalCount)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kSFDidFinishLoadingNotification object:self];
                    
                    [self saveChanges];
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error){
                NSLog(@"Get image %@: %@", url, error);
                progress++;
                if (progress == totalCount)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kSFDidFinishLoadingNotification object:self];
                    
                    [self saveChanges];
                }
            }];
            [operation start];
        }
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kSFDidFinishLoadingNotification object:self];
    }
#endif
}

#pragma mark - archive

- (BOOL)saveChanges
{
    NSString *path = [self archivePathForKey:kSFImageKeysArchiveName];
    
    return [NSKeyedArchiver archiveRootObject:self.cachedImageKeys toFile:path];
}

- (NSString *)archivePathForKey:(NSString *)key
{
    NSString *cacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];

    return [cacheDirectory stringByAppendingString:[NSString stringWithFormat:@"/%@", key]];
}

@end
