//
//  ColorsDefine.h
//  SobotSDK
//
//  Created by 张新耀 on 15/8/5.
//  Copyright (c) 2015年 sobot. All rights reserved.
//

#import "ZCUITools.h"


////////////////////////////////////////////////////////////
/**
 *  字体
 */
#define  ZCUIFont20       [UIFont fontWithName:@"Helvetica" size:20]
#define  ZCUIFontBold20   [UIFont fontWithName:@"Helvetica-Bold" size:20]

#define  ZCUIFont18       [UIFont fontWithName:@"Helvetica" size:18]
#define  ZCUIFontBold18   [UIFont fontWithName:@"Helvetica-Bold" size:18]

#define  ZCUIFont17       [UIFont fontWithName:@"Helvetica" size:17]
#define  ZCUIFontBold17   [UIFont fontWithName:@"Helvetica-Bold" size:17]
// 字体
#define ZCUIFontSTHeitiSC17(f) [UIFont fontWithName:@"STHeitiSC-Light" size:f]

#define  ZCUIFont16       [UIFont fontWithName:@"Helvetica" size:16]
#define  ZCUIFontBold16   [UIFont fontWithName:@"Helvetica-Bold" size:16]


#define  ZCUIFont15       [UIFont fontWithName:@"Helvetica" size:15]
#define  ZCUIFontBold15   [UIFont fontWithName:@"Helvetica-Bold" size:15]

#define  ZCUIFont14       [UIFont fontWithName:@"Helvetica" size:14]
#define  ZCUIFontBold14   [UIFont fontWithName:@"Helvetica-Bold" size:14]

#define  ZCUIFont13       [UIFont fontWithName:@"Helvetica" size:13]
#define  ZCUIFontBold13   [UIFont fontWithName:@"Helvetica-Bold" size:13]

#define  ZCUIFont12       [UIFont fontWithName:@"Helvetica" size:12]
#define  ZCUIFontBold12   [UIFont fontWithName:@"Helvetica-Bold" size:12]

#define  ZCUIFont11       [UIFont fontWithName:@"Helvetica" size:11]
#define  ZCUIFontBold11   [UIFont fontWithName:@"Helvetica-Bold" size:11]

#define  ZCUIFont10       [UIFont fontWithName:@"Helvetica" size:10]
#define  ZCUIFontBold10   [UIFont fontWithName:@"Helvetica-Bold" size:10]


#define  ZCUIFont8       [UIFont fontWithName:@"Helvetica" size:8]
#define  ZCUIFontBold8   [UIFont fontWithName:@"Helvetica-Bold" size:8]


#define UIColorFromThemeColor(themeColorKey) [ZCUITools getZCThemeColorByKey:themeColorKey]
#define UIColorFromThemeColorAlpha(themeColorKey,a) [ZCUITools getZCThemeColorAlphaByKey:themeColorKey alpha:a]

// 颜色取值方法
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define COLORWithAlpha(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define UIColorFromRGBAlpha(rgbValue,a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]

#define ZCColorWithWhiteAlpha(w,a) [UIColor colorWithWhite:w alpha:a]

////////////////////////////////////////////////////////////
/**
 *  颜色
 */
//<!-- 主题色薄荷绿  -->
#define ZCThemeColor @"ZCThemeColor" // 0x0DAEAF
//<!-- 链接色 蓝色  -->
#define ZCTextLinkBlueColor @"ZCTextLinkBlueColor"// 0x4D9DFE
//<!-- 链接色-右边气泡中  -->
#define ZCTextLinkYellowColor @"ZCTextLinkYellowColor" //0xFFEEAA
//<!-- 警告色  -->
#define ZCTextWarnRedColor @"ZCTextWarnRedColor" // 0xF06A7C
//<!-- 公告正文  -->
#define ZCTextNoticeColor @"ZCTextNoticeColor" // 0x99734C
//<!-- 公告链接色链接色  -->
#define ZCTextNoticeLinkColor @"ZCTextNoticeLinkColor" // 0xE67F17

//<!-- 主要文本色  -->
#define ZCTextMainColor @"ZCTextMainColor" // 0x515A7C
//<!-- 次要文本色  -->
#define ZCTextSubColor @"ZCTextSubColor" // 0xACB5C4

//<!-- 占位文本色  -->
#define ZCTextPlaceHolderColor @"ZCTextPlaceHolderColor" // 0xDDE0E6

//<!-- 白色背景  -->
#define ZCBgSystemWhiteColor @"ZCBgSystemWhiteColor" // 0xFFFFFF

//<!-- 白色背景,转浅黑背景  -->
#define ZCBgSystemWhiteLightDarkColor @"ZCBgSystemWhiteLightDarkColor" // 0xFFFFFF

//<!-- 白色文字  -->
#define ZCTextSystemWhiteColor @"ZCTextSystemWhiteColor" // 0xFFFFFF

//<!-- 左侧聊天气泡默认颜色 -->
#define ZCBgLeftChatColor @"ZCBgLeftChatColor" // 0xF2F5F7
//<!-- 通告背景颜色 -->
#define ZCBgNoticeColor @"ZCBgNoticeColor" // 0xFFFDF4D1
//<!-- 线条颜色 -->
#define ZCBgLineColor @"ZCBgLineColor" // 0xEDEEF0

//<!-- 浅灰色背景、留言、帮助中心 转一级灰色背景 -->
#define ZCBgLightGrayColor @"ZCBgLightGrayColor" // 0xF8F9FA

#define ZCBgChatLightGrayColor @"ZCBgChatLightGrayColor" // 0xF8F9FA

//<!-- 浅灰色背景、留言、帮助中心,暗黑对应纯黑 -->
#define ZCBgLightGrayDarkColor @"ZCBgLightGrayDarkColor" // 0xF8F9FA

//<!-- 导航背景色 -->
#define ZCBgTopBannerColor @"ZCBgTopBannerColor" // 0xFFFFFF


//<!-- 不管什么模式，都是白色 -->
#define ZCKeepWhiteColor @"ZCKeepWhiteColor" // 0xFFFFFF

//<!-- 转浅灰色第二级别 -->
#define ZCBgSystemWhiteLightGrayColor @"ZCBgSystemWhiteLightGrayColor" // 0xFFFFFF


//<!-- 第二级别转浅聊天第三级别灰色 -->
#define ZCBgSystemWhiteThirdGrayColor @"ZCBgSystemWhiteThirdGrayColor" // 0x353538





// 无网络提醒颜色
#define BgNetworkFailColor  0xe4e4e4
#define TextNetworkTipColor 0x666666



/**
 *  黑色
 *
 *  @return 颜色为0x000000
 */
#define TextBlackColor     0x000000



////////////////////////////////////


/**
 *  取消发送
 *
 *  @return 颜色为0xa05857
 */
#define BgVoiceRedColor    0xa05857



/**
 *  清空聊天记录红色
 *
 *  @return
 */
#define TextCleanMessageColor    0xe64340



/**
 *  多轮会话中不可点击的背景色（历史记录使用）
 *  //0xd6dbe5
 */
#define multiWheelBgColor   0xf2f2f2


/**
 提醒背景颜色
 */
#define ZCToastBgColor 0x566573
