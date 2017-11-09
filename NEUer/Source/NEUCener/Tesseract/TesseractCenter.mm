//
//  TesseractCenter.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/22.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "TesseractCenter.h"
#import <GPUImage/GPUImage.h>

@interface TesseractCenter () <G8TesseractDelegate>

@end

@implementation TesseractCenter

static TesseractCenter * center;

#pragma mark - Singleton

+ (instancetype)defaultCenter {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        center = [[TesseractCenter alloc] init];
    });
    
    return center;
}

- (void)setup {
    [self setupTesseract];
}

- (void)setupTesseract {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        _tesseract = [[G8Tesseract alloc] initWithLanguage:@"eng" engineMode:G8OCREngineModeTesseractOnly];
        _tesseract.charBlacklist = @"';!~`^,.><‘’˙˚º°“”′";
        _tesseract.delegate = self;
    });
}

#pragma mark - G8TesseractDelegate

- (UIImage *)preprocessedImageForTesseract:(G8Tesseract *)tesseract sourceImage:(UIImage *)sourceImage {
    GPUImage3x3ConvolutionFilter *filter = [[GPUImage3x3ConvolutionFilter alloc] init];
    UIImage *newImage = [filter imageByFilteringImage:sourceImage];
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImageView *imageView = [[UIImageView alloc] initWithImage:newImage];
        imageView.layer.borderWidth = 1;
        imageView.layer.borderColor = [UIColor redColor].CGColor;
        imageView.frame = CGRectMake(0, 100, sourceImage.size.width, sourceImage.size.height);
        [[UIApplication sharedApplication].keyWindow addSubview:imageView];
    });
    return newImage;
}

@end
