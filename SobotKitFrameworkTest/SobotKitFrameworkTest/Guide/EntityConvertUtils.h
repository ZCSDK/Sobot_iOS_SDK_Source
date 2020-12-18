//
//  EntityConvertUtils.h
//  SobotKitFrameworkTest
//
//  Created by 张新耀 on 2020/1/8.
//  Copyright © 2020 zhichi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SobotKit/SobotKit.h>

// 设备屏幕尺寸的宽度
#define ScreenWidth                      [[UIScreen mainScreen] bounds].size.width

// 设备屏幕尺寸的高度
#define ScreenHeight                     [[UIScreen mainScreen] bounds].size.height


// iPhoneX
#define ZC_iPhoneX ([[UIApplication sharedApplication].delegate window].safeAreaInsets.bottom > 0)

#define SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

// 导航栏的高度
//#define NavBarHeight                        (ZC_iPhoneX ? 88.f : (iOS7 ? 64.0 : 44.0))
#define NavBarHeight                        (ZC_iPhoneX ? 88.f : ( SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(@"11.0") ? 64.0 : 0))

// 状态栏的高度
#define StatusBarHeight                     (ZC_iPhoneX ? 44.f : (iOS7 ? 0.0 : 20.0))

#define TabBarHeight                       49


#define isiPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define ZCScreenScale         (isiPad ? 1.0 : (ScreenWidth / 375.0f))

#define ZCNumber(num)          (num*ZCScreenScale)



#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


NS_ASSUME_NONNULL_BEGIN

@interface EntityConvertUtils : NSObject

@property(nonatomic,strong) ZCLibInitInfo *libInitInfo;
@property(nonatomic,strong) ZCKitInfo *kitInfo;
@property(nonatomic,strong) NSString *apiHost;

+(EntityConvertUtils *)getEntityConvertUtils;


-(void)saveMessageToEntity:(NSString *) jsonString;

-(NSString *)getJsonStringByTooldsByKeys:(NSArray *) keys;

-(void)setDefaultConfiguration;

// UIColor转#ffffff格式的字符串
+ (NSString *)hexStringFromColor:(UIColor *)color;
+ (UIColor *) colorWithHexString: (NSString *) hexString;
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;
+(NSString*)DataTOjsonString:(id)object;

NSString *convertToString(id object);
@end

NS_ASSUME_NONNULL_END
