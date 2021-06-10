//
//  ZCToolsCore.h
//  SobotKit
//
//  Created by zhangxy on 2018/1/29.
//  Copyright © 2018年 zhichi. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void(^AlertViewBlock)(NSInteger buttonTag);
/**
 工具类
 如：
    图片处理
    获取图片地址
 
 */
@interface ZCToolsCore : NSObject

+(ZCToolsCore *)getToolsCore;

// 检测图片中的二维码,返回 一个URL 字符串，或者nil
-(id )coderURLStrDetectorWith:(UIImage *)image;

- (void)setRTLFrame:(UIView *)view;

-(void)clear;

/**
 *  创建提示框
 *
 *  @param title        标题
 *  @param message      提示内容
 *  @param cancelTitle  取消按钮(无操作,为nil则只显示一个按钮)
 *  @param titleArray   标题字符串数组(为nil,默认为"确定")
 *  @param vc           VC iOS8及其以后会用到
 *  @param confirm      点击按钮的回调(取消按钮的Index是 -1)
 */
- (void)showAlert:(NSString *)title
          message:(NSString *)message
      cancelTitle:(NSString *)cancelTitle
       titleArray:(NSArray *)titleArray
   viewController:(UIViewController *)vc
          confirm:(AlertViewBlock)confirm;

/**
 *  创建提示框(可变参数版)
 *
 *  @param title        标题
 *  @param message      提示内容
 *  @param cancelTitle  取消按钮(无操作,为nil则只显示一个按钮)
 *  @param vc           VC iOS8及其以后会用到
 *  @param confirm      点击按钮的回调(取消按钮的Index是 -1)
 *  @param buttonTitles 按钮(为nil,默认为"确定",传参数时必须以nil结尾，否则会崩溃)
 */
- (void)showAlert:(NSString *)title
          message:(NSString *)message
      cancelTitle:(NSString *)cancelTitle
   viewController:(UIViewController *)vc
          confirm:(AlertViewBlock)confirm
     buttonTitles:(NSString *)buttonTitles, ... NS_REQUIRES_NIL_TERMINATION;


/// 处理 识别出的链接
/// @param viewController 当前控制器
- (void)dealWithLinkClickWithLick:(NSString *)link viewController:(UIViewController *)viewController;




/// 0上，1左，2右
-(int)getCurScreenDirection;



/// 根据当前table坐标，横屏时的适配坐标
/// @param tableView  要适配的table
-(CGRect )settingPortraitOrLandspace:(UITableView *) tableView;



-(UIWindow *)getCurWindow;

@end
