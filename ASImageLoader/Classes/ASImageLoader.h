//
//  ASImageLoader.h
//  ASGraphQLClient
//
//  Created by Stanislav Pletnev on 15.09.17.
//  Copyright © 2017 Anobisoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASImagePresenterProtocol.h"

@interface ASImageLoader : NSObject

@property (class) NSTimeInterval requestTimeout;
@property (class) NSUInteger cacheMemoryCapacity;
@property (class) NSUInteger cacheDiskCapacity;
@property (class) NSString *placeholderImageName;

+ (UIImage *)imageFetch:(void (^)(UIImage *image, NSError *error))fetch withURL:(NSURL *)URL;
+ (void)imageFetchWithURL:(NSURL *)URL
                  forCell:(id<ASImagePresenter>)cell
                   inView:(__weak UIView *)view // UITableView or UICollectionView
              atIndexPath:(NSIndexPath *)indexPath;

+ (instancetype)new NS_UNAVAILABLE;
+ (instancetype)allocWithZone:(struct _NSZone *)zone NS_UNAVAILABLE;
+ (instancetype)alloc NS_UNAVAILABLE;

@end
