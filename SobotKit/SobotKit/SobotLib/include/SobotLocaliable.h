//
//  SobotLocaliable.h
//  SobotCommon
//
//  Created by zhangxy on 2021/8/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// SobotLocalizable
FOUNDATION_EXPORT NSString * const SobotLocaliableTableName;

// zh-Hans
FOUNDATION_EXPORT NSString * const SobotLocaliableDefaultLanguage;

// SobotKit
FOUNDATION_EXPORT NSString * const SobotLocaliableDefaultBundleName;

// SobotLocalizable
FOUNDATION_EXPORT NSString * const SobotLocaliablePathInBundle;

@interface SobotLocaliable : NSObject

// 默认语言
@property (strong, nonatomic) NSString * default_language;
// 指定语言
@property (strong, nonatomic) NSString * absolute_language;

// 语言文件所在的bundle
@property (strong, nonatomic) NSString * bundle_name;

// 语言文件在bundle中的路径
@property (strong, nonatomic) NSString * path_inbundle;

// 语言文件名称
@property (strong, nonatomic) NSString * table_name;

// 是否关闭镜像功能 默认支持 如果设置YES 在阿拉伯文的场景下将关闭镜像设置
@property (assign,nonatomic) BOOL isCloseSystemRTL;

+(SobotLocaliable *)shareSobotLocaliable;

// 指定属性有效
-(NSString * )sobotGetLocalString:(NSString *)key;


// 使用默认值直接访问，指定属性无效
+(NSString *)sobotGetDefaultString:(NSString *) key;
+(NSString *)sobotGetDefaultString:(NSString *)key lan:(NSString *) absoluteLanguage;

/**
 *   获取当前的手机语言
 *
 */
+(NSString *)sobotGetCurrentLanguages;

@end

NS_ASSUME_NONNULL_END
