//
//  ZCVideoPlayer.h
//  SobotKit
//
//  Created by zhangxy on 2018/11/30.
//  Copyright © 2018年 zhichi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZCVideoPlayer : UIView

- (instancetype)initWithFrame:(CGRect)frame withShowInView:(UIView *)bgView url:(NSURL *)url Image:(UIImage *)image;

@property (copy, nonatomic) NSURL *videoUrl;

- (void)stopPlayer;

-(void)showControlsView;

@end

NS_ASSUME_NONNULL_END
