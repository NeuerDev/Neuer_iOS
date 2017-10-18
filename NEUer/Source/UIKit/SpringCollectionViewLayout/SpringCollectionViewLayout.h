//
//  SpringCollectionViewLayout.h
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/18.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SpringCollectionViewLayout : UICollectionViewFlowLayout
@property (nonatomic, assign) CGFloat springDamping;
@property (nonatomic, assign) CGFloat springFrequency;
@property (nonatomic, assign) CGFloat resistanceFactor;
@end
