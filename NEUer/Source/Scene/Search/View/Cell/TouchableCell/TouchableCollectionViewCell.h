//
//  TouchableCollectionViewCell.h
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/24.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TouchableCollectionViewCell : UICollectionViewCell

- (void)touchedDownInside;

- (void)touchedUpInside;

- (void)touchedDownUpCancel;

@end
