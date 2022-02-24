//
//  ZCSobot.m
//  SobotKit
//
//  Created by zhangxy on 15/11/12.
//  Copyright © 2015年 zhichi. All rights reserved.
//

#import "ZCSobot.h"
#import "ZCLibClient.h"

#import "ZCPlatformTools.h"
#import "ZCUICore.h"

#import "ZCServiceCentreVC.h"
#import "ZCLocalStore.h"
#import "ZCSobotApi.h"


@implementation ZCSobot

+(void)startZCChatVC:(ZCKitInfo *) info
                with:(UIViewController *) byController
              target:(id<ZCChatControllerDelegate>) delegate
           pageBlock:(void (^)(id object,ZCPageBlockType type))pageClick
    messageLinkClick:(BOOL (^)(NSString *link)) messagelinkBlock{
    
    [ZCSobotApi openZCChat:info with:byController target:delegate pageBlock:pageClick messageLinkClick:messagelinkBlock];
}

+(void)openZCServiceCentreVC:(ZCKitInfo *) info
                         with:(UIViewController *) byController
                       onItemClick:(void (^)(ZCUIBaseController *object))itemClickBlock{
    [ZCSobotApi openZCServiceCenter:info with:byController onItemClick:itemClickBlock];
}



+(void)startZCChatListView:(ZCKitInfo *)info with:(UIViewController *)byController onItemClick:(void (^)(ZCUIChatListController *object,ZCPlatformInfo *info))itemClickBlock{
    [ZCSobotApi openZCChatListView:info with:byController onItemClick:itemClickBlock];
}

+(void)getMessageLinkClick:(BOOL (^)(NSString *link))messagelinkBlock{
    [ZCSobotApi setMessageLinkClick:messagelinkBlock];
}


+(void)sendLocation:(NSDictionary *)locations{
    [ZCSobotApi sendLocation:locations resultBlock:nil];
}

+(void)sendProductInfo:(ZCProductInfo *)pinfo{
    [ZCSobotApi sendProductInfo:pinfo resultBlock:nil];
}



+(void)sendOrderGoodsInfo:(ZCOrderGoodsModel *)orderGoodsInfo{
    [ZCSobotApi sendOrderGoodsInfo:orderGoodsInfo resultBlock:nil];
}

+(void)sendTextToUser:(NSString *)textMsg{
    [ZCSobotApi sendTextToUser:textMsg resultBlock:nil];
}

+(void)customConnectUserService:(ZCLibMessage *) message kitInfo:(ZCKitInfo*)uiInfo type:(int) trunType{
    [ZCSobotApi connectCustomerService:message KitInfo:uiInfo ZCTurnType:trunType];
}


+(BOOL)getPlatformIsArtificialWithAppkey:(NSString *)appkey Uid:(NSString*)uid{
    return [ZCSobotApi getPlatformIsArtificialWithAppkey:appkey Uid:uid];
}



+(void)backgroundInitSDK:(void (^)(NSString *,int code))ResultBlock{
    [ZCSobotApi synchronizationInitInfoToSDK:ResultBlock];
}


+(void)checkConfig:(void (^)(NSString *,int code))ResultBlock{
    if ([@"" isEqualToString:sobotConvertToString([ZCLibClient getZCLibClient].libInitInfo.app_key)] && [@"" isEqualToString:sobotConvertToString([ZCLibClient getZCLibClient].libInitInfo.customer_code)]) {
        if(ResultBlock){
            ResultBlock(@"appkey不能为空",1);
        }
        return;
    }
    
    
    
    if(([[ZCPlatformTools sharedInstance] getPlatformInfo].config == nil) || ![[ZCLibClient getZCLibClient].libInitInfo.partnerid isEqual:[[ZCPlatformTools sharedInstance] getPlatformInfo].config.zcinitInfo.partnerid]){
        [self backgroundInitSDK:ResultBlock];
    }else{
        if(ResultBlock){
            ResultBlock(@"Success",0);
        }
    }
    
    
}


+(void)openLeanve:(int ) showRecored kitinfo:(ZCKitInfo *)kitInfo with:(UIViewController *)byController onItemClick:(void (^)(NSString *, int))CloseBlock{
    [ZCSobotApi openLeave:showRecored kitinfo:kitInfo with:byController onItemClick:CloseBlock];
}



+(NSString *)getVersion {
    return [ZCLibClient sobotGetSDKVersion];
}


+(NSString *)getChannel{
    return [ZCLibClient sobotGetAppChannel];
}

+(NSString *)getAppVersion{
    return sobotGetAppVersion();
}

+(NSString *)getiphoneType{
    return sobotGetIphoneType();
}


+(NSString *)getAppName{
    return sobotGetAppName();
}

+(void)setShowDebug:(BOOL)isShowDebug{
    [ZCSobotApi setShowDebug:isShowDebug];
}

+(NSString *)getsystorm{
    return sobotGetSystemVersion();
}




@end
