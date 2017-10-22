//
//  TesseractCenter.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/22.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "TesseractCenter.h"

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
    return sourceImage;
}

@end
