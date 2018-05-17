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

@property (nonatomic) NSTimeInterval requestTimeout;
@property (nonatomic) NSUInteger cacheMemoryCapacity;
@property (nonatomic) NSUInteger cacheDiskCapacity;
@property (nonatomic) NSString *placeholderImageName;

+ (instancetype)defaultLoader;

- (UIImage *)imageFetch:(void (^)(UIImage *image, NSError *error))fetch withURL:(NSURL *)URL;
- (void)imageFetchWithURL:(NSURL *)URL
                  forCell:(id<ASImagePresenter>)cell
                   inView:(__weak UIView *)view // UITableView or UICollectionView
              atIndexPath:(NSIndexPath *)indexPath;

@end
