//
//  UIColor+JHCategory.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/18.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "UIColor+JHCategory.h"

@implementation UIColor (JHCategory)

#pragma mark - colorWithHexStr:

+ (UIColor *)colorWithHexStr:(NSString *)hexString {
    
    if (!hexString) return [UIColor clearColor];
    
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString: @"#" withString: @""] uppercaseString];
    
    CGFloat alpha, red, blue, green;
    
    switch ([colorString length]) {
        case 0:
            return [UIColor clearColor];
        case 3: // #RGB
            alpha = 1.0f;
            red   = [self colorComponentFrom: colorString start: 0 length: 1];
            green = [self colorComponentFrom: colorString start: 1 length: 1];
            blue  = [self colorComponentFrom: colorString start: 2 length: 1];
            break;
        case 4: // #ARGB
            alpha = [self colorComponentFrom: colorString start: 0 length: 1];
            red   = [self colorComponentFrom: colorString start: 1 length: 1];
            green = [self colorComponentFrom: colorString start: 2 length: 1];
            blue  = [self colorComponentFrom: colorString start: 3 length: 1];
            break;
        case 6: // #RRGGBB
            alpha = 1.0f;
            red   = [self colorComponentFrom: colorString start: 0 length: 2];
            green = [self colorComponentFrom: colorString start: 2 length: 2];
            blue  = [self colorComponentFrom: colorString start: 4 length: 2];
            break;
        case 8: // #AARRGGBB
            alpha = [self colorComponentFrom: colorString start: 0 length: 2];
            red   = [self colorComponentFrom: colorString start: 2 length: 2];
            green = [self colorComponentFrom: colorString start: 4 length: 2];
            blue  = [self colorComponentFrom: colorString start: 6 length: 2];
            break;
        default:
            alpha = 0;
            red = 0;
            blue = 0;
            green = 0;
            break;
    }
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (CGFloat)colorComponentFrom:(NSString *)string start:(NSUInteger)start length:(NSUInteger)length {
    NSString *substring = [string substringWithRange: NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat: @"%@%@", substring, substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString: fullHex] scanHexInt: &hexComponent];
    return hexComponent / 255.0f;
}

+ (UIColor *)beautyRed {
    return [self colorWithHexStr:@"#FF3B30"];
}

+ (UIColor *)beautyOrange {
    return [self colorWithHexStr:@"#FF9500"];
}

+ (UIColor *)beautyYellow {
    return [self colorWithHexStr:@"#FFCC00"];
}

+ (UIColor *)beautyGreen {
    return [self colorWithHexStr:@"#4CD964"];
}

+ (UIColor *)beautyTealBlue {
    return [self colorWithHexStr:@"#5AC8FA"];
}

+ (UIColor *)beautyBlue {
    return [self colorWithHexStr:@"#007AFF"];
}

+ (UIColor *)beautyPurple {
    return [self colorWithHexStr:@"#5856D6"];
}

+ (UIColor *)beautyPink {
    return [self colorWithHexStr:@"#5856D6"];
}

#pragma mark - colorToImage

- (UIImage *)image {
    return [self imageWithSize:CGSizeMake(CGFLOAT_MIN, CGFLOAT_MIN)];
}

- (UIImage *)imageWithSize:(CGSize)size {
    if (!self)
        return nil;
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size,NO, 0);
    CGContextRef context =UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, self.CGColor);
    CGContextFillRect(context, rect);
    UIImage *image =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIColor *)compressRangeColor {
    const CGFloat* colors = CGColorGetComponents(self.CGColor);
    CGFloat total = colors[0]+colors[1]+colors[2];
    if (total>224.0f*3) {
        float scale = 224.0f/total/255.0f;
        return [UIColor colorWithRed:colors[0]*scale green:colors[1]*scale blue:colors[2]*scale alpha:1.0];
    }
    
    if ((colors[0]+colors[1]+colors[2])<32.0f*3) {
        float scale = 224.0f/total/255.0f;
        return [UIColor colorWithRed:colors[0]*scale green:colors[1]*scale blue:colors[2]*scale alpha:1.0];
    }
    
    return self;
}

+ (UIColor *)randomColor {
    NSArray *randomColorArray = @[
                                  [UIColor beautyYellow],
                                  [UIColor beautyTealBlue],
                                  [UIColor beautyPurple],
                                  [UIColor beautyPink],
                                  random(253, 195, 90),
                                  random(96, 238, 165),
                                  random(248, 220, 101),
                                  random(121, 233, 234),
                                  random(253, 159, 215),
                                  random(135, 177, 251),
                                  random(253, 161, 128),
                                  random(211, 143, 246),
                                  random(176, 235, 70),
                                  random(121, 233, 234)
                                  ];
    int i = arc4random() % randomColorArray.count;
    
    return randomColorArray[i];
}

@end
