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


@end

NS_ASSUME_NONNULL_END
