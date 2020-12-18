//
//  ZCLogUtils.h
//  XcodeUtils
//
//  Created by zhangxy on 16/3/9.
//  Copyright © 2016年 zhangxy. All rights reserved.
//

#import <Foundation/Foundation.h>

#define Log_WS_Flag           0     // 输出日志开关【切记，上线时关闭】 0关闭 1 开启
#define Log_WS_Info_Flag      1     // 输出日志开关
#define Log_WS_Error_Flag     1     // 输出日志开关
#define Log_WS_Warning_Flag   1     // 输出日志开关
#define Log_WS_Debug_Flag     0     // 输出日志开关【切记，上线时关闭】 0关闭 1 开启

#define Log_Cache_Flag        1     // 保存日志总开关
#define Log_Cache_ErrorFlag   1     // 总开关下 错误日志保存
#define Log_Cache_InfoFlag    1     // 总开关下 消息日志保存
#define Log_Cache_WarningFlag 1     // 总开关下 警告日志保存
#define Log_Cache_DebugFlag   1     // 总开关下 警告日志保存
#define Log_Cache_CustomFlag  1     // 总开关下 自定义日志保存

// 日志输出头，再方法内部不能获取方法和行号，需要调用时传递
#define LogHeader [NSString stringWithFormat:@"\n=======================\n%@ %@\n%s[%d]",[[NSBundle mainBundle] bundleIdentifier],[NSDate date],__FUNCTION__,__LINE__]

#define ZCKey_ISDEBUG @"ZCKey_ISDEBUG"

typedef NS_ENUM(NSInteger,ZCLogType) {
    ZCLogTypeInfo           = 0,
    ZCLogTypeStartSDK       = 1,
    ZCLogTypeStartApp       = 2,
    ZCLogTypeUnknowError    = 3, // 写入
    ZCLogTypeError          = 4, // 写入
    ZCLogTypeException      = 5, // 写入
    ZCLogTypeDebug          = 6, // 写入
};


@interface ZCLogUtils : NSObject

/**
 *  输出指定标签日志
 *
 *  @param log    日志内容
 *  @param header 日志行号、方法名称,直接传递LogHeader宏定义即可
 */
+(void)logText:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

// 外部日志开关控制输出内容
+(void)logHeader:(NSString *) header info:(NSString *)format, ... NS_FORMAT_FUNCTION(2,3);

// 开发调试使用
+(void)logHeader:(NSString *) header debug:(NSString *)format, ... NS_FORMAT_FUNCTION(2,3);
+(void)logHeader:(NSString *) header error:(NSString *)format, ... NS_FORMAT_FUNCTION(2,3);
+(void)logHeader:(NSString *) header warning:(NSString *)format, ... NS_FORMAT_FUNCTION(2,3);



/**
写入日志信息
 
 @param title 日志标题
 @param message 日志内容
 @param logType 日志类型(必须大于0)，1错误、2异常、3日志
 */
+(void)cacheLog:(NSString *) title content:(NSString *)message logType:(ZCLogType) logType;
/**
 *  根据设定的过期时长，清理日志，默认是1天
 */
+(void)cleanCache;

+(void)writefile:(NSString *)string withPath:(NSString *) filePath;


/**
 根据路径清理文件

 @param filePath 
 */
+(void)cleanCache:(NSString *) filePath;


/**
 获取统计日志

 @return 
 */
+(NSString * )getAnalysisFilePath;


/**
 获取日志文件列表

 @return 日志路径
 */
+(NSMutableArray *) getLogFileList;

/**
 *  获取缓存日志
 *
 *  @return 缓存日志路径，当天
 */
+(NSString * )getLogFilePath;

/**
 *  获取缓存日志
 *
 *  @param dateString 具体哪一天的日志，格式yyyyMMdd
 *
 *  @return 缓存日志路径
 */
+(NSString * )getLogFilePath:(NSString *) dateString;



/**
 *  读取文件内容
 *
 *  @param filePath 文件完整路径，可通过getLogFilePath(:)获取
 *
 *  @return 文件内容
 */
+(NSString *) readFileContent:(NSString *) filePath;


/**
 读取堆栈信息

 @return NSString数组
 */
+(NSArray *)readBacktrace;
@end
