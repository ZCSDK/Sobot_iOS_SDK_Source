//
//  ZCSobot.m
//  SobotKit
//
//  Created by zhangxy on 15/11/12.
//  Copyright © 2015年 zhichi. All rights reserved.
//

#import "ZCSobot.h"
#import "ZCLibClient.h"
#import "ZCLogUtils.h"

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


+(void)turnServiceWithGroupId:(NSString *)groupId  Obj:(id)obj KitInfo:(ZCKitInfo*)uiInfo ZCTurnType:(NSInteger)turnType Keyword:(NSString*)keyword KeywordId:(NSString*)keywordId{
    [ZCSobotApi connectCustomerService:groupId Obj:obj KitInfo:uiInfo ZCTurnType:turnType Keyword:keyword KeywordId:keywordId];
}


+(BOOL)getPlatformIsArtificialWithAppkey:(NSString *)appkey Uid:(NSString*)uid{
    return [ZCSobotApi getPlatformIsArtificialWithAppkey:appkey Uid:uid];
}



+(void)backgroundInitSDK:(void (^)(NSString *,int code))ResultBlock{
    [ZCSobotApi synchronizationInitInfoToSDK:ResultBlock];
}


+(void)checkConfig:(void (^)(NSString *,int code))ResultBlock{
    if ([@"" isEqualToString:zcLibConvertToString([ZCLibClient getZCLibClient].libInitInfo.app_key)] && [@"" isEqualToString:zcLibConvertToString([ZCLibClient getZCLibClient].libInitInfo.customer_code)]) {
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
    return zcGetSDKVersion();
}


+(NSString *)getChannel{
    return zcGetAppChannel();
}

+(NSString *)getAppVersion{
    return zcGetAppVersion();
}

+(NSString *)getiphoneType{
    return zcGetIphoneType();
}


+(NSString *)getAppName{
    return zcGetAppName();
}

+(void)setShowDebug:(BOOL)isShowDebug{
    [ZCSobotApi setShowDebug:isShowDebug];
}

+(NSString *)getsystorm{
    return zcGetSystemVersion();
}




@end
