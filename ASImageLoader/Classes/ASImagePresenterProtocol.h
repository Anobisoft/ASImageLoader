//
//  ASImagePresenter.h
//  ASGraphQLClient
//
//  Created by Stanislav Pletnev on 15.09.17.
//  Copyright © 2017 Anobisoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ASImagePresenter <NSObject>
@required
- (void)setImage:(UIImage *)image;

@optional
- (UIActivityIndicatorView *)activityIndicator;

@end
