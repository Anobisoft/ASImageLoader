//
//  ASImageLoader.m
//  ASGraphQLClient
//
//  Created by Stanislav Pletnev on 15.09.17.
//  Copyright © 2017 Anobisoft. All rights reserved.
//

#import "ASImageLoader.h"
#import <AnobiKit/AnobiKit.h>

#define ASImageLoaderDefaults_requestTimeout 30
#define ASImageLoaderDefaults_cacheMemoryCapacity 4 * 0x100000
#define ASImageLoaderDefaults_cacheDiskCapacity 64 * 0x100000

#pragma mark - UIView

@interface UIView (ASImageLoader)
    
- (id)cellAtIndexPath:(NSIndexPath *)ip;
- (void)reloadCellAtIndexPath:(NSIndexPath *)ip;

@end

#pragma mark - UITableView

@implementation UITableView (ASImageLoader)
    
- (id)cellAtIndexPath:(NSIndexPath *)ip {
    return [self cellForRowAtIndexPath:ip];
}

- (void)reloadCellAtIndexPath:(NSIndexPath *)ip {
    [self beginUpdates];
    [self reloadRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self endUpdates];
}

@end

#pragma mark - UICollectionView

@implementation UICollectionView (ASImageLoader)
    
- (id)cellAtIndexPath:(NSIndexPath *)ip {
    return [self cellForItemAtIndexPath:ip];
}

- (void)reloadCellAtIndexPath:(NSIndexPath *)ip {
    @try {
        [self reloadItemsAtIndexPaths:@[ip]];
    } @catch (NSException *exception) {
        NSLog(@"[ERROR] %@", exception);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadCellAtIndexPath:ip];
        });
    }
}

@end

#pragma mark -
#pragma mark - ASImageLoader

@interface ASImageLoader()

@property (readonly) NSMutableSet *failedURLs;
@property (readonly) NSCache *cache;

@end

@implementation ASImageLoader

@synthesize cacheMemoryCapacity = _cacheMemoryCapacity;
@synthesize failedURLs = _failedURLs;
@synthesize cache = _cache;


+ (instancetype)defaultLoader {
    static id defaultInstance = nil;
    dispatch_syncmain(^{
        if (!defaultInstance) {
            defaultInstance = [self new];
        }        
    });
    return defaultInstance;
}

#pragma mark - Cache

- (NSUInteger)cacheMemoryCapacity {
    return _cacheMemoryCapacity;
}

- (void)setCacheMemoryCapacity:(NSUInteger)cacheMemoryCapacity {
    if (cacheMemoryCapacity != _cacheMemoryCapacity) {
        _cacheMemoryCapacity = cacheMemoryCapacity;
        [self configureCache];
    }
}

static NSUInteger _cacheDiskCapacity;

- (NSUInteger)cacheDiskCapacity {
    return _cacheDiskCapacity;
}

- (void)setCacheDiskCapacity:(NSUInteger)cacheDiskCapacity {
    if (cacheDiskCapacity != _cacheDiskCapacity) {
        _cacheDiskCapacity = cacheDiskCapacity;
        [self configureCache];
    }
}

- (void)configureCache  {
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:self.cacheMemoryCapacity diskCapacity:self.cacheDiskCapacity diskPath:nil];
    [NSURLCache setSharedURLCache:sharedCache];
}

#pragma mark - Request timeout

static NSUInteger _requestTimeout;

- (NSTimeInterval)requestTimeout {
    return _requestTimeout;
}

- (void)setRequestTimeout:(NSTimeInterval)requestTimeout {
    if (requestTimeout > 0) _requestTimeout = requestTimeout;
}


#pragma mark -

- (instancetype)init {
    if (self = [super init]) {
        self.requestTimeout = ASImageLoaderDefaults_requestTimeout;
        _cacheMemoryCapacity = ASImageLoaderDefaults_cacheMemoryCapacity;
        _cacheDiskCapacity = ASImageLoaderDefaults_cacheDiskCapacity;
        
        @try {
            NSDictionary *config = [[AKConfigManager manager] configWithName:self.class.description];
            if (config) {
                NSNumber *timeoutNumber = config[@"requestTimeout"];
                if (timeoutNumber) {
                    NSTimeInterval timepout = timeoutNumber.doubleValue;
                    if (timepout > 0) {
                        self.requestTimeout = timepout;
                    }
                }
                
                NSNumber *cacheMemoryCapacityNumber = config[@"cacheMemoryCapacity"];
                if (cacheMemoryCapacityNumber) {
                    NSUInteger cacheMemoryCapacity = cacheMemoryCapacityNumber.unsignedIntegerValue;
                    _cacheMemoryCapacity = cacheMemoryCapacity;
                }
                NSNumber *cacheDiskCapacityNumber = config[@"cacheDiskCapacity"];
                if (cacheDiskCapacityNumber) {
                    NSUInteger cacheDiskCapacity = cacheDiskCapacityNumber.unsignedIntegerValue;
                    _cacheDiskCapacity = cacheDiskCapacity;
                }
            }
        } @catch (NSException *exception) {
            NSLog(@"[ERROR] Exception: %@", exception);
        } @finally {
            [self configureCache];
        }
    }
    return self;
}


#pragma mark -

- (UIImage *)imageFetch:(void (^)(UIImage *image, NSError *error))fetch withURL:(NSURL *)URL {
    if (!URL || [self.failedURLs containsObject:URL]) {
        return self.placeholder ?: [NSNull null];
    }
    
    UIImage *cachedImage = [self.cache objectForKey:URL];
    if (cachedImage) {
        return cachedImage;
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:URL cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:self.requestTimeout];
    NSCachedURLResponse *cachedResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
    if (cachedResponse) {
        NSData *data = cachedResponse.data;
        if (data) {
            UIImage *image = [UIImage imageWithData:data];
            if (image) {
                [self.cache setObject:image forKey:URL];
                return image;
            }
        }
    }
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"[ERROR] %@", error);
            if (error.code == NSURLErrorUnsupportedURL) {
                [self.failedURLs addObject:URL];
            }
        }
        if (fetch) {
            UIImage *image = nil;
            @try {
                if (data) {
                    image = [UIImage imageWithData:data];
                    if (image) [self.cache setObject:image forKey:URL];
                }
            } @catch (NSException *exception) {
                NSLog(@"[ERROR] Exception: %@", exception);
            } @finally {
                fetch(image ?: self.placeholder, error);
            }
        }
    }] resume];
    
    return nil;
}


BOOL ASImagePresenterHasActivityIndicator(id<ASImagePresenter> imagePresenter) {
    return [imagePresenter respondsToSelector:@selector(activityIndicator)] && imagePresenter.activityIndicator && [imagePresenter.activityIndicator isKindOfClass:[UIActivityIndicatorView class]];
}

void ASImagePresenterSetImage(id<ASImagePresenter> imagePresenter, UIImage *image) {
    if ([image isKindOfClass:[UIImage class]]) {
        [imagePresenter setImage:image];
    } else {
        [imagePresenter setImage:nil];
    }
}

void ASImagePresenterStartAnimating(id<ASImagePresenter> imagePresenter) {
    if (ASImagePresenterHasActivityIndicator(imagePresenter)) {
        [imagePresenter.activityIndicator startAnimating];
    }
}

void ASImagePresenterStopAnimating(id<ASImagePresenter> imagePresenter) {
    if (ASImagePresenterHasActivityIndicator(imagePresenter)) {
        [imagePresenter.activityIndicator stopAnimating];
    }
}

- (void)imageFetchWithURL:(NSURL *)URL
                  forCell:(id<ASImagePresenter>)cell
                   inView:(__weak UIView *)view
              atIndexPath:(NSIndexPath *)indexPath {

    UIImage *cachedImage = [self imageFetch:^(UIImage *image, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (view == nil) return;
            id ipcell = [view cellAtIndexPath:indexPath];
            if (ipcell == nil) {
                [view reloadCellAtIndexPath:indexPath];
                return;
            }
            if ([ipcell conformsToProtocol:@protocol(ASImagePresenter)]) {
                ASImagePresenterSetImage(ipcell, image);
                ASImagePresenterStopAnimating(ipcell);
            }
        });
    } withURL:URL];
                  
    if ([cell conformsToProtocol:@protocol(ASImagePresenter)]) {
        if (cachedImage) {
            ASImagePresenterStopAnimating(cell);
            ASImagePresenterSetImage(cell, cachedImage);
        } else {
            ASImagePresenterStartAnimating(cell);
            ASImagePresenterSetImage(cell, self.placeholder);
        }
    }
}

@end
