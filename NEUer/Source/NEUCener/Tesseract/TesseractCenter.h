//
//  TesseractCenter.h
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/22.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <TesseractOCR/G8Tesseract.h>
#import <Foundation/Foundation.h>

@interface TesseractCenter : NSObject

@property (nonatomic, strong) G8Tesseract *tesseract;

+ (instancetype)defaultCenter;
- (void)setup;
@end
