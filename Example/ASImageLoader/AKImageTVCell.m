//
//  AKImageTVCell.m
//  ASImageLoader
//
//  Created by Stanislav Pletnev on 24.03.2018.
//  Copyright © 2018 Anobisoft. All rights reserved.
//

#import "AKImageTVCell.h"

@interface AKImageTVCell()
@property (weak, nonatomic) IBOutlet UIImageView *imageV;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation AKImageTVCell

- (void)setImage:(UIImage *)image {
    self.imageView.image = image;
}

@end
