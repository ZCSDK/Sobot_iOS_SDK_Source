//
//  SocotCommon.h
//  SobotSDK
//
//  Created by 张新耀 on 15/8/5.
//  Copyright (c) 2015年 sobot. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 *   ZC 公共的类
 *
 *   获取sdk版本号 获取应用BunddleID 获取渠道名称 日期格式 计算日期与当前时间的差 验证手机、邮箱、qq、拼音 md5 hash 获取Library路径
 */
@interface ZCLibSobotCommon : NSObject

/**
 *  空对象转行成@""
 *
 *  @param object 传入的不定对象
 *
 *  @return 字符串
 */
NSString *zcLibConvertToString(id object);

/**
 * do md5 hash
 ***/
NSString* zcLibMd5(NSString* input);
NSString *MD5Hash(NSString * input);

BOOL zcLibIsUrl(NSString *urlString);


NSString *zcUrlEncodedString(NSString *url);

/**
 *  去掉尾部空格
 *
 *  @param input 要去掉的空格
 *
 *  @return
 */
NSString* zcLibTrimString (NSString* input);

/**
 *  判断nil
 *
 *  @param object
 *
 *  @return
 */
BOOL zcLibIs_null(id object);

/**
 *  判断@""
 *
 *  @param str
 *
 *  @return
 */
BOOL zcLibIsEmpty(NSString* str);


// 验证
BOOL zcLibValidateEmail(NSString* email);
BOOL zcLibValidateMobile(NSString* mobile);
BOOL zcLibValidateMobileWithRegex(NSString* mobile,NSString *regex);
BOOL zcLibValidateQQNumber(NSString *qqNumber);
// 纯数字
BOOL zcLibValidateNumber(NSString *str);
BOOL zcLibValiddatePinYin(NSString *pinYin);

/**
 判断最多2位小数

 @param str 字符串
 @return yes/no
 */
BOOL zcLibValidateDecimalDouble(NSString *str);


/**
 * 字母、数字、中文正则判断（不包括空格）
 */
BOOL zcLibValidateRuleNotBlank(NSString *str);

/**
 * extract the file name from path
 *
 **/
NSString* zcLibExtractFileNameFromPath(NSString* path);


/**
 *  get the Tmp path of download file
 *
 ***/
NSString* zcLibGetTmpDownloadFilePath(NSString* filePath);

/**
 *  get cache file path
 ***/
NSString* zcLibGetCacheFilePath(NSString* cacheKey);

//获取Library路径
NSString* zcLibGetLibraryFilePath(const NSString* fileName);

NSString* zcLibGetDocumentsFilePath(const NSString* fileName);

NSString* zcLibGetResourcePath(NSString* basePath, NSString* resName, NSString* resType);

NSURL* zcLibGetResourceUrl(NSString* basePath, NSString* resName, NSString* resType);


BOOL zcLibCheckFileIsExsis(NSString *filePath);
BOOL zcLibCheckFilePathIsExsis(NSString *filePath);

/*删除文件 指向目录为（NSCachesDirectory）临时文件夹*/
BOOL zcLibDeleteFileAtPath(NSString *filePath);


//检查路径，没有就创建路径
BOOL zcLibCheckPathAndCreate(NSString *path);

//检查路径文件，没有就创建路径和文件
BOOL zcLibCheckFileAndCreate(NSString *filePath);


/**
 *  日期格式
 *
 *  @param fromate 格式
 *  @param date    要格式的日期
 *
 *  @return 格式化后的字符串
 */
NSString * zcLibDateTransformString(NSString* fromate,NSDate*date);

/**
 *  longlong类型日期，转换为字符串
 *
 *  @param fromate  格式
 *  @param longdate 转换的类型，主要php和java日期精确度不一样
 *
 *  @return <#return value description#>
 */
NSString * zcLibLongdateTransformString(NSString* fromate,long long longdate);


/// 获取北京时区的时间
/// @param fromate  SobotFormateTime
NSString * zcLibCurrentDateFormateString(NSString* fromate);

/**
 *  字符串转日期
 *
 *  @param stringDate <#stringDate description#>
 *
 *  @return <#return value description#>
 */
NSDate * zcLibStringFormateDate(NSString * stringDate);


/// 计算时间与当前时间的差，单位秒，如果是分钟需要除以60
/// @param theDate
NSTimeInterval zcLibDiffTimeSinceNow(NSString *theDate);
/**
 *  计算日期与当前时间的差
 *
 *  @param theDate 要对比的日期
 *
 *  @return 刚刚、几分钟前、几小时前、几天前、日期
 */
NSString *zcLibIntervalSinceNow(NSString *theDate);

/**
 *  获取日期的年
 *
 *  @param date 要获取的日期
 *
 *  @return 返回哪一年
 */
NSInteger zcLibGetDataYear(NSDate *date);


/**
 *  获取sdk版本号
 *
 *  @return 版本号字符串
 */
NSString * zcGetSDKVersion();

/**
 *  获取渠道名称
 *
 *  @return 渠道
 */
NSString *zcGetAppChannel();


/**
 获取当前是否为电商版本
 非电商版本，无法使用电商版本功能

 @return
 */
BOOL isPlatformUnion();

/**
 *  获取应用BunddleID
 *
 *  @return
 */
NSString *zcGetAppBunddleID();

/**
 *  显示日志信息
 *
 *  @return 
 */
BOOL isDebug();



/**
 *  获取设备的系统
 *
 */
NSString *zcGetSystemVersion();
double zcGetSystemDoubleVersion();


/**
 *  获取app的名称
 *
 */
NSString *zcGetAppName();

/**
 *  获取app的版本号
 *
 */
NSString *zcGetAppVersion();

/**
 *  获取手机型号
 *
 */
NSString *zcGetIphoneType();

// 获取文件类型
int zcLibmimeWithURLType(NSString *filePath);


/**
 *  获取运营商信息
 *
 */
NSString *zcGetIphoneOperators();


/**
 *  获取当前手机设置的语言
 *  return  是否是英语
 *  服务端使用
 **/
int  zcGetAppLanguages();

/**
 获取当前语言文件前缀名称
 */
NSString *zcGetLanguagePrefix();
NSString * zcTestLocalString(NSString *key);

/**
 *   获取当前的手机语言
 *
 */
NSString *zcGetCurrentLanguages();



/// 判断当前是否需要从右往左显示
BOOL isRTLLayout();

/**
 *  获取当前的分辨率
 *
 */
NSString *zcGetScreenScale();


/**
 *  获取设备的尺寸
 *
 */
NSString *zcGetScreenHeightAndWidth();



/// 判断是否刘海屏
BOOL zcIsIPhoneX();

@end
