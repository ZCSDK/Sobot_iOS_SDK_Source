//
//  GlobalDefine.h
//  SobotSDK
//
//  Created by 张新耀 on 15/8/5.
//  Copyright (c) 2015年 sobot. All rights reserved.
//
#import "ZCLibClient.h"
#import "ZCLibCommon.h"


// UTF8 字符串
#define UTF8Data(str) [str dataUsingEncoding:NSUTF8StringEncoding]



// 应用程序代理
#define ApplicationDelegate                 ((AppDelegate *)[[UIApplication sharedApplication] delegate])


// 是否为iOS7或者iOS7以上的版本，如果设备版本<iOS7 返回NO 否则返回YES
#define iOS7                                ((floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)? NO:YES)


// 是否为竖屏
#define isPortrait                          ([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationPortrait || [[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationPortraitUpsideDown)


// 格式化转换(int转String)
#define IntToString(x)                      [NSString stringWithFormat:@"%d",x]


// 获取NSUserDefaults对象
#define UserDefaults                        [NSUserDefaults standardUserDefaults]


// 获取发送通知对象
#define NOTIFICATION_CENTER                 [NSNotificationCenter defaultCenter]


// 设备屏幕尺寸的宽度
#define SysScreenWidth                      [[UIScreen mainScreen] bounds].size.width

// 设备屏幕尺寸的高度
#define SysScreenHeight                     [[UIScreen mainScreen] bounds].size.height




// 屏幕旋转后宽度的尺寸
#define ScreenWidth                         (isPortrait ? MIN(SysScreenWidth,SysScreenHeight) : MAX(SysScreenWidth,SysScreenHeight))

// 屏幕旋转后高度的尺寸
#define ScreenHeight                        (isPortrait ? MAX(SysScreenWidth,SysScreenHeight) : MIN(SysScreenWidth,SysScreenHeight))


// iPhoneX
#define ZC_iPhoneX zcIsIPhoneX() //(((SysScreenWidth == 375.f && SysScreenHeight == 812.f ) ||(SysScreenHeight == 375.f && SysScreenWidth == 812.f ) || (SysScreenHeight == 414.f && SysScreenWidth == 896.f ) || (SysScreenWidth == 414.f && SysScreenHeight == 896.f ))? YES : NO)

// 导航栏的高度
#define isLandspace     ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight || [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft)
#define NavLandspaceBarHeight               ([UIApplication sharedApplication].statusBarHidden?44:64.0)
#define NavBarHeight                        (isLandspace ? NavLandspaceBarHeight : (ZC_iPhoneX ? 88.f : (iOS7 ? 64.0 : 44.0)))


// 状态栏的高度
#define StatusBarHeight                     (ZC_iPhoneX ? 44.f : (iOS7 ? 0.0 : 20.0))

#define XBottomBarHeight                    (ZC_iPhoneX ? (isLandspace?20:34.f) : 0.0)

#define isiPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define ZCScreenScale        1.0f// (isiPad ? 1.0 : (ScreenWidth / 375.0f))

#define ZCNumber(num)         (num*ZCScreenScale)

// 底部弹出标题高度
#define ZCSheetTitleHeight   60

// View的宽度
#define ViewWidth(v)                        v.frame.size.width

// View的高度
#define ViewHeight(v)                       v.frame.size.height

// View的X轴坐标
#define ViewX(v)                            v.frame.origin.x

// View的Y轴坐标
#define ViewY(v)                            v.frame.origin.y


// 多语言支持
//#define ZCSTLocalString(key) NSLocalizedStringFromTable(key, @"SobotLocalizable", nil)
#define ZCSTLocalString(key) \
({\
NSString *v = nil;\
NSString * sourcePath = @"";\
NSString * bundlePath = [[NSBundle mainBundle] pathForResource:@"SobotKit" ofType:@"bundle"];\
if([ZCLibClient getZCLibClient].libInitInfo!=nil && [ZCLibClient getZCLibClient].libInitInfo.absolute_language!=nil){\
    sourcePath = [bundlePath stringByAppendingFormat:@"/SobotLocalizable/%@",[ZCLibClient getZCLibClient].libInitInfo.absolute_language];\
    if(![NSBundle bundleWithPath:sourcePath]){\
        sourcePath = @"";\
        NSString *jsonPath = zcLibGetDocumentsFilePath([NSString stringWithFormat:@"/sobot/ios_%@_%@.json",zcGetSDKVersion(),[ZCLibClient getZCLibClient].libInitInfo.absolute_language]);\
        if(zcLibCheckFileIsExsis(jsonPath)){\
           NSData *data=[NSData dataWithContentsOfFile:jsonPath];\
           NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];\
           if(dict && [[dict allKeys] containsObject:key]){\
               v = dict[key];\
           }\
        }\
    }\
}\
if(v==nil && sourcePath.length == 0){\
    sourcePath = [bundlePath stringByAppendingPathComponent:[NSString stringWithFormat:@"SobotLocalizable/%@_lproj",zcGetLanguagePrefix()]];\
    if(![NSBundle bundleWithPath:sourcePath]){\
        if([ZCLibClient getZCLibClient].libInitInfo!=nil && [ZCLibClient getZCLibClient].libInitInfo.default_language!=nil){\
            sourcePath = [bundlePath stringByAppendingPathComponent:[NSString stringWithFormat:@"SobotLocalizable/%@",[ZCLibClient getZCLibClient].libInitInfo.default_language]];\
        }else{\
            sourcePath = [bundlePath stringByAppendingPathComponent:@"SobotLocalizable/en_lproj"];\
        }\
    }\
}\
if(sourcePath.length > 0){\
    NSBundle *resourceBundle = [NSBundle bundleWithPath:sourcePath];\
    v = [resourceBundle localizedStringForKey:key value:@"" table:@"SobotLocalizable"];\
}\
(v==nil ? key : zcLibConvertToString(v));\
})
