//
//  LibraryRecommendModel.h
//  NEUer
//
//  Created by kl h on 2017/11/7.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LibraryRecommedDelegate <NSObject>
- (void)recommendDidSuccess;
- (void)recommendDidFail:(NSString *)errorMessage;
@end

@interface LibraryRecommendModel : NSObject
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *language;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSString *press;
@property (nonatomic, strong) NSString *yearOfPublication;
@property (nonatomic, strong) NSString *recommendNum;
@property (nonatomic, strong) NSString *recommendReason;
@property (nonatomic, strong) NSString *ISBN;
@property (nonatomic, strong) NSString *price;
@property (nonatomic, strong) NSString *REC_key;

@property (nonatomic, weak) id <LibraryRecommedDelegate> delegate;

- (void)recommend;

@end
