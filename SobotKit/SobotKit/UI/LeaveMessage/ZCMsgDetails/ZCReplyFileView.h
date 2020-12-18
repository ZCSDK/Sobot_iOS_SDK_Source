//
//  ZCReplyFileView.h
//  SobotKit
//
//  Created by xuhan on 2019/12/9.
//  Copyright © 2019 zhichi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^ZCReplyFileViewClickBlock)(NSDictionary* modelDic , UIImageView *imgView);

@interface ZCReplyFileView : UIView

- (instancetype)initWithDic:(NSDictionary *)modelDic withFrame:(CGRect )frame;

@property (nonatomic , assign) NSInteger viewTag;

@property (nonatomic , copy) ZCReplyFileViewClickBlock clickBlock;

@end

NS_ASSUME_NONNULL_END
