//
//  JHMarco.h
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/25.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#ifndef JHMarco_h
#define JHMarco_h

#define WS(weakself) __weak __typeof(&*self) weakself = self
#define SCREEN_WIDTH_ACTUAL (([UIScreen mainScreen].bounds.size.width < [UIScreen mainScreen].bounds.size.height)?[UIScreen mainScreen].bounds.size.width:[UIScreen mainScreen].bounds.size.height)
#define SCREEN_HEIGHT_ACTUAL (([UIScreen mainScreen].bounds.size.width > [UIScreen mainScreen].bounds.size.height)?[UIScreen mainScreen].bounds.size.width:[UIScreen mainScreen].bounds.size.height)
#define NEU_MAIN_COLOR @"#F3BE40"
#endif /* JHMarco_h */
