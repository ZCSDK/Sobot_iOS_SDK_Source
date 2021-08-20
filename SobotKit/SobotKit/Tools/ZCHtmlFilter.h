//
//  ZCHtmlFilter.h
//  SobotKit
//
//  Created by zhangxy on 2019/4/25.
//  Copyright © 2019 zhichi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


/**
 过来html表情，解析A，B，I标签
 */
@interface ZCHtmlFilter : NSObject



/**
 设置带html属性到label标签上

 @param text 过滤掉html的字符串
 @param attrs 解析出来的属性列表
 @param label 要设置的控件
 @return
 */
+(NSMutableAttributedString *)setHtml:(NSString *)text attrs:(NSMutableArray *) attrs view:(UILabel *) label  textColor:(UIColor*)textColor textFont:(UIFont*)textFont linkColor:(UIColor*)linkColor;

/**
 单独处理引导语 设置带html属性到label标签上

 @param text 过滤掉html的字符串
 @param attrs 解析出来的属性列表
 @param label 要设置的控件
 @return
 */
+(NSMutableAttributedString *)setGuideHtml:(NSString *)text attrs:(NSMutableArray *) attrs view:(UILabel *) label  textColor:(UIColor*)textColor textFont:(UIFont*)textFont linkColor:(UIColor*)linkColor;



/// 设置聊天页信息
/// @param label 要设置的Label
/// @param text 要设置的text字符串
/// @param isRight 是否为右侧显示，获取默认字体和颜色
+(void) addChatTextToLabel:(UILabel *)label text:(NSString *)text chatLayout:(BOOL) isRight result:(void(^)(NSMutableAttributedString *attr)) attrBlock;


/// 设置label的富文本
/// @param label 要设置的Label
/// @param text 原始html字符串
/// @param textColor 文字颜色
/// @param textFont 字体
/// @param linkColor 链接颜色
+(void) addTextToLabel:(UILabel *)label text:(NSString *)text textColor:(UIColor *)textColor textFont:(UIFont *)textFont linkColor:(UIColor *)linkColor result:(void(^)(NSMutableAttributedString *attr)) attrBlock;


/// 获取格式化的富文本字符串，用于存储到基础数据中
/// @param text 原始html字符串
/// @param textColor 文字颜色
/// @param textFont 字体
/// @param linkColor 链接颜色
+(NSMutableAttributedString *)createMutalText:(NSString *)text textColor:(UIColor *)textColor textFont:(UIFont *)textFont linkColor:(UIColor *)linkColor;


@end

NS_ASSUME_NONNULL_END
