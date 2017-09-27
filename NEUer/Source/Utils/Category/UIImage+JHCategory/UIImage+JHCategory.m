//
//  UIImage+JHCategory.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/24.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "UIImage+JHCategory.h"

@implementation UIImage (JHCategory)

- (UIColor*)mainColor {
    int size = 8;
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
    int bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast;
#else
    int bitmapInfo = kCGImageAlphaPremultipliedLast;
#endif
    
    //第一步 先把图片缩小 加快计算速度. 但越小结果误差可能越大
    CGSize thumbSize=CGSizeMake(size, size);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 thumbSize.width,
                                                 thumbSize.height,
                                                 8,//bits per component
                                                 thumbSize.width*4,
                                                 colorSpace,
                                                 bitmapInfo);
    
    CGRect drawRect = CGRectMake(0, 0, thumbSize.width, thumbSize.height);
    CGContextDrawImage(context, drawRect, self.CGImage);
    CGColorSpaceRelease(colorSpace);
    
    unsigned char *data = CGBitmapContextGetData (context);
    
    if (data == NULL) return nil;
    
    int totalR = 0, totalG = 0, totalB = 0;
    
    for (int x=0; x<thumbSize.width; x++) {
        for (int y=0; y<thumbSize.height; y++) {
            int offset = 4*(x*y);
            totalR += data[offset];
            totalG += data[offset+1];
            totalB += data[offset+2];
        }
    }
    CGContextRelease(context);
    int totalCount = size*size;
    int meanR = totalR/totalCount, meanG = totalG/totalCount, meanB = totalB/totalCount;
    
    return [UIColor colorWithRed:(float)meanR/255.0f green:(float)meanG/255.0f blue:(float)meanB/255.0f alpha:1.0];
}
@end
