//
//  TelevisionChannelModel.h
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/26.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TelevisionChannelModel : NSObject

@end

@interface TelevisionChannelScheduleBean : NSObject

@property (nonatomic, strong) NSString *issue;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *videoUrl;

@end
