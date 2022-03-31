//
//  ZCUILoading.h
//  SobotKit
//
//  Created by lizhihui on 15/11/11.
//  Copyright © 2015年 zhichi. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  智齿loading页面
 */
@interface ZCUILoading : UIView

/**
 *  单例
 */
+ (ZCUILoading*)shareZCUILoading;


/**
 *  展示
 *  @param  SuperView 智齿loading要展示的父类View
 */
- (void)showAddToSuperView:(UIView*)SuperView style:(BOOL) isLagerWhite;


/**
 *  消失
 */
- (void)dismiss;



/// 网络错误提示
/// @param title 描述
/// @param image 顶部logo，默认网络错误图标
/// @param SuperView 要显示到那个view上
/// @param clickblock 点击刷新按钮
- (void)createPlaceholderView:(NSString *)title image:(UIImage *)image withView:(UIView *)SuperView action:(void (^)(UIButton *button)) clickblock;

@end
