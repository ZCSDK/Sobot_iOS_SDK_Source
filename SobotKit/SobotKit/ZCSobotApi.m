//
//  ZCSobotApi.m
//  SobotKit
//
//  Created by xuhan on 2020/1/17.
//  Copyright © 2020 zhichi. All rights reserved.
//

#import "ZCSobotApi.h"

//#import "ZCLibClient.h"
#import "ZCLogUtils.h"

#import "ZCPlatformTools.h"
#import "ZCUICore.h"

#import "ZCServiceCentreVC.h"
#import "ZCLocalStore.h"
#import "UIDeviceTools.h"
#import "ZCMsgDetailsVC.h"
#import "ZCIMChat.h"
#import "ZCLibGlobalDefine.h"

@implementation ZCSobotApi

+(void)initSobotSDK:(NSString *)appkey result:(void (^)(id _Nonnull))resultBlock{
    [self initSobotSDK:appkey host:@"" result:resultBlock];
}

+(void)initSobotSDK:(NSString *) appkey host:(NSString *) apiHost result:(void (^)(id object))resultBlock{
    [[ZCLibClient getZCLibClient] initSobotSDK:appkey host:apiHost result:resultBlock];

     [ZCSobotApi synchronizeLanguage:[ZCLibClient getZCLibClient].libInitInfo.absolute_language write:NO result:nil];
}

//  打开会话页面
+(void)openZCChat:(ZCKitInfo *)info with:(UIViewController *)byController pageBlock:(void (^)(id _Nonnull, ZCPageBlockType))pageClick{
    [self openZCChat:info with:byController target:nil pageBlock:pageClick messageLinkClick:nil];
}
//  打开会话页面
+ (void)openZCChat:(ZCKitInfo *) info
            with:(UIViewController *) byController
        target:(id<ZCChatControllerDelegate>) delegate
       pageBlock:(void (^)(id object,ZCPageBlockType type))pageClick
    messageLinkClick:(BOOL (^)(NSString *link)) messagelinkBlock{
     if(byController==nil){
         return;
     }
     if(info == nil){
         return;
     }
     
     if ([@"" isEqualToString:zcLibConvertToString([ZCLibClient getZCLibClient].libInitInfo.app_key)] && [@"" isEqualToString:zcLibConvertToString([ZCLibClient getZCLibClient].libInitInfo.customer_code)]) {
         return;
     }
    
     if (messagelinkBlock != nil) {
         [[ZCUICore getUICore] setLinkClickBlock:messagelinkBlock];
     }
     
     [[ZCUICore getUICore] setPageLoadBlock:pageClick];
    
    [[ZCUICore getUICore] setKitInfo:info];
    
     ZCChatController *chat=[[ZCChatController alloc] initWithInitInfo:info];
     chat.chatdelegate = delegate;
     chat.hidesBottomBarWhenPushed = [ZCUICore getUICore].kitInfo.ishidesBottomBarWhenPushed;
     
     if(byController.navigationController==nil){
         chat.isPush = NO;
         UINavigationController * navc = [[UINavigationController alloc]initWithRootViewController: chat];
         navc.modalPresentationStyle = UIModalPresentationOverFullScreen;
         // 设置动画效果
         [byController presentViewController:navc animated:YES completion:^{

         }];
     }else{
         chat.isPush = YES;
         [byController.navigationController pushViewController:chat animated:YES];
     }
     
     //清理过期日志 v2.7.9
     [ZCLogUtils cleanCache];
    
}

+(void)setMessageLinkClick:(BOOL (^)(NSString * _Nonnull))messagelinkBlock{
    if (messagelinkBlock != nil) {
        [[ZCUICore getUICore] setLinkClickBlock:messagelinkBlock];
    }
}

// 打开客户中心页面
+ (void)openZCServiceCenter:(ZCKitInfo *) info
                         with:(UIViewController *) byController
                  onItemClick:(void (^)(ZCUIBaseController *object))itemClickBlock {
    
    if(byController==nil){
            return;
        }
        if(info == nil){
            return;
        }
        
        if ([@"" isEqualToString:zcLibConvertToString([ZCLibClient getZCLibClient].libInitInfo.app_key)] && [@"" isEqualToString:zcLibConvertToString([ZCLibClient getZCLibClient].libInitInfo.customer_code)]) {
            return;
        }
        
        ZCServiceCentreVC *chat=[[ZCServiceCentreVC alloc] initWithInitInfo:info];
        [chat setOpenZCSDKTypeBlock:itemClickBlock];
        chat.hidesBottomBarWhenPushed = [ZCUICore getUICore].kitInfo.ishidesBottomBarWhenPushed;
        chat.kitInfo = info;
        if(byController.navigationController==nil){
            chat.isPush = NO;
            UINavigationController * navc = [[UINavigationController alloc]initWithRootViewController: chat];
            navc.modalPresentationStyle = UIModalPresentationOverFullScreen;
            // 设置动画效果
            [byController presentViewController:navc animated:YES completion:^{
                
            }];
        }else{
            chat.isPush = YES;
            [byController.navigationController pushViewController:chat animated:YES];
        }
    
}

// 打开消息中心页面
+ (void)openZCChatListView:(ZCKitInfo *)info with:(UIViewController *)byController onItemClick:(void (^)(ZCUIChatListController *object,ZCPlatformInfo *info))itemClickBlock {
    
    if(byController==nil){
        return;
    }
    if(info == nil){
        return;
    }
    ZCUIChatListController *chat=[[ZCUIChatListController alloc] init];
    chat.hidesBottomBarWhenPushed = [ZCUICore getUICore].kitInfo.ishidesBottomBarWhenPushed;
    chat.kitInfo = info;
    [chat setOnItemClickBlock:itemClickBlock];
    chat.byController = byController;
    if(byController.navigationController==nil){
          UINavigationController * navc = [[UINavigationController alloc]initWithRootViewController:chat];
              // 设置动画效果
              navc.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [byController presentViewController:chat animated:YES completion:^{
            
        }];
    }else{
        [byController.navigationController pushViewController:chat animated:YES];
    }
    
}

// 打开留言页面
+ (void)openLeave:(int ) showRecored kitinfo:(ZCKitInfo *)kitInfo with:(UIViewController *)byController onItemClick:(void (^)(NSString *msg,int code))CloseBlock {
    
    [ZCUICore getUICore].kitInfo = kitInfo;

    [ZCSobotApi checkConfig:^(NSString *msg, int code) {
        if(code == 0){

            ZCUILeaveMessageController *leaveMessageVC = [[ZCUILeaveMessageController alloc]init];
            leaveMessageVC.hidesBottomBarWhenPushed = YES;
            leaveMessageVC.exitType = 2;
        //    leaveMessageVC.isShowToat = isShow;
        //    leaveMessageVC.tipMsg = msg;
            leaveMessageVC.isNavOpen = (byController.navigationController!=nil ? YES: NO);
            leaveMessageVC.ticketShowFlag = 1;

            ZCLibConfig *config = [[ZCPlatformTools sharedInstance] getPlatformInfo].config;
            leaveMessageVC.enclosureShowFlag = config.enclosureShowFlag;
            leaveMessageVC.enclosureFlag = config.enclosureFlag;
            leaveMessageVC.telFlag = config.telFlag;
            leaveMessageVC.emailFlag = config.emailFlag;
            leaveMessageVC.telShowFlag = config.telShowFlag;
            leaveMessageVC.emailShowFlag =  config.emailShowFlag;
            leaveMessageVC.msgTmp =  config.msgTmp;
            leaveMessageVC.msgTxt = config.msgTxt;
            
            [leaveMessageVC setCloseBlock:^{
                if(CloseBlock){
                    CloseBlock(@"关闭留言页面",0);
                }
            }];

            if(showRecored > 0){
                // 直接跳转到 留言记录、
                leaveMessageVC.selectedType = 2;
                leaveMessageVC.ticketShowFlag  = (showRecored == 1)?0:1;
            }

            if(byController.navigationController==nil){
                UINavigationController * navc = [[UINavigationController alloc]initWithRootViewController: leaveMessageVC];
                // 设置动画效果
                navc.modalPresentationStyle = UIModalPresentationOverFullScreen;
                [byController presentViewController:navc animated:YES completion:^{

                }];
            }else{
                [byController.navigationController pushViewController:leaveMessageVC animated:YES];
            }
        }else{
            if(CloseBlock){
                CloseBlock(msg,code);
            }
        }
    }];
    
}

+(void)openRecordDetail:(NSString *)ticketId viewController:(UIViewController *) byController{
    ZCMsgDetailsVC * detailVC = [[ZCMsgDetailsVC alloc]init];
    detailVC.ticketId = zcLibConvertToString(ticketId);
    detailVC.companyId = [ZCSobotApi getCommanyId];
    if (byController.navigationController!= nil) {
        [byController.navigationController pushViewController:detailVC animated:YES];
    }else{

        UINavigationController * navc = [[UINavigationController alloc]initWithRootViewController: detailVC];
        // 设置动画效果
        navc.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [byController presentViewController:navc animated:YES completion:^{
            
        }];
    }
}

+(NSString *)getCommanyId{
    return [ZCLocalStore getLocalParamter:@"ZCKEY_COMPANYID"];
}

// 发送位置
+ (void)sendLocation:(NSDictionary *) locations resultBlock:(nonnull void (^)(NSString * _Nonnull, int))ResultBlock{
    if([[ZCUICore getUICore] getLibConfig].isArtificial){
        [[ZCUICore getUICore] sendMessage:locations[@"file"] questionId:@"" type:ZCMessageTypeLocation duration:@"" dict:locations];
        if(ResultBlock){
            ResultBlock(@"执行了接口调用",0);
        }
    }else{
        if(ResultBlock){
            ResultBlock(@"当前是不是人工客服状态，不能给人工发送消息",1);
        }
    }
}

// 发送文字消息
+ (void)sendTextToUser:(NSString *)textMsg resultBlock:(nonnull void (^)(NSString * _Nonnull, int))ResultBlock{
    [self sendMessageToUser:textMsg type:ZCMessageTypeText resultBlock:ResultBlock];
}

+ (void)sendMessageToUser:(NSString *)textMsg type:(NSInteger ) msgType resultBlock:(nonnull void (^)(NSString * _Nonnull, int))ResultBlock{
    if([[ZCUICore getUICore] getLibConfig].isArtificial){
        [[ZCUICore getUICore] sendMessage:textMsg questionId:@"" type:msgType duration:@"" dict:nil];
        if(ResultBlock){
            ResultBlock(@"执行了接口调用",0);
        }
    }else{
        if(ResultBlock){
               ResultBlock(@"当前是不是人工客服状态，不能给人工发送消息",1);
        }
    }
}

// 发送订单卡片
+ (void)sendOrderGoodsInfo:(ZCOrderGoodsModel *)orderGoodsInfo resultBlock:(nonnull void (^)(NSString * _Nonnull, int))ResultBlock{
    
    if(orderGoodsInfo){

        NSMutableDictionary * contentDic = [NSMutableDictionary dictionaryWithCapacity:5];
        NSString *contextStr = @"";
        [contentDic setObject:[NSString stringWithFormat:@"%d",orderGoodsInfo.orderStatus] forKey:@"orderStatus"];
        [contentDic setObject:zcLibConvertToString(orderGoodsInfo.createTime) forKey:@"createTime"];
        [contentDic setObject:zcLibConvertToString(orderGoodsInfo.orderCode) forKey:@"orderCode"];
        [contentDic setObject:zcLibConvertToString(orderGoodsInfo.createTime) forKey:@"createTime"];
        [contentDic setObject:orderGoodsInfo.goods forKey:@"goods"];
        [contentDic setObject:zcLibConvertToString(orderGoodsInfo.orderUrl) forKey:@"orderUrl"];
        [contentDic setObject:zcLibConvertToString(orderGoodsInfo.goodsCount) forKey:@"goodsCount"];
        [contentDic setObject:zcLibConvertToString(orderGoodsInfo.totalFee) forKey:@"totalFee"];
        // 转json
        contextStr = [ZCLocalStore DataTOjsonString:contentDic];
        
        // 仅人工时才可以发送
        if([[ZCUICore getUICore] getLibConfig].isArtificial){
            [[ZCUICore getUICore] sendMessage:contextStr questionId:@"" type:ZCMessageTypeOrder duration:@"" dict:nil];
            if(ResultBlock){
                ResultBlock([NSString stringWithFormat:@"执行了接口调用:%@",contextStr],0);
            }
        }else{
            if(ResultBlock){
                   ResultBlock(@"当前是不是人工客服状态，不能给人工发送消息",1);
            }
        }
        
        
    }
    
}

// 发送商品卡片
+ (void)sendProductInfo:(ZCProductInfo *)productInfo resultBlock:(nonnull void (^)(NSString * _Nonnull, int))ResultBlock{
    
    if(productInfo){
        
        NSMutableDictionary * contentDic = [NSMutableDictionary dictionaryWithCapacity:5];
        NSString *contextStr = @"";
        [contentDic setObject:[NSString stringWithFormat:@"%@",zcLibConvertToString(productInfo.title)] forKey:@"title"];
        
        [contentDic setObject:[NSString stringWithFormat:@"%@",zcLibConvertToString(productInfo.desc)] forKey:@"description"];
        
        [contentDic setObject:[NSString stringWithFormat:@"%@",zcLibConvertToString(productInfo.label)] forKey:@"label"];
        
        [contentDic setObject:[NSString stringWithFormat:@"%@",zcLibConvertToString(productInfo.link)] forKey:@"url"];
        
        [contentDic setObject:[NSString stringWithFormat:@"%@",zcLibConvertToString(productInfo.thumbUrl)] forKey:@"thumbnail"];
        // 转json
        contextStr = [ZCLocalStore DataTOjsonString:contentDic];
        
        // 仅人工时才可以发送
        if([[ZCUICore getUICore] getLibConfig].isArtificial){
            [[ZCUICore getUICore] sendMessage:contextStr questionId:@"" type:ZCMessageTypeCard duration:@""];
            if(ResultBlock){
                ResultBlock(@"执行了接口调用",0);
            }
        }else{
            if(ResultBlock){
                   ResultBlock(@"当前是不是人工客服状态，不能给人工发送消息",1);
            }
        }
        
    }
    
}

// 给机器人发送消息
+ (void)sendTextToRobot:(NSString *)textMsg{
    [[ZCUICore getUICore]  sendMessage:textMsg questionId:@"" type:ZCMessageTypeText duration:@"" dict:nil];
}

// 同步用户信息
+ (void)synchronizationInitInfoToSDK:(void (^)(NSString *msg,int code))ResultBlock {
    if ([@"" isEqualToString:zcLibConvertToString([ZCLibClient getZCLibClient].libInitInfo.app_key)] && [@"" isEqualToString:zcLibConvertToString([ZCLibClient getZCLibClient].libInitInfo.customer_code)]) {
        if(ResultBlock){
            ResultBlock(@"appkey不能为空",1);
        }
        return;
    }
    ZCKitInfo *kitInfo = [ZCUICore getUICore].kitInfo;
    if (!kitInfo) {
        kitInfo = [ZCKitInfo new];
    }
    
    
    [[ZCUICore getUICore] openSDKWith:[ZCLibClient getZCLibClient].libInitInfo uiInfo:kitInfo Delegate:nil blcok:^(ZCInitStatus code, NSMutableArray *arr, NSString *result) {
        if(code == ZCInitStatusLoadSuc){
            if(ResultBlock){
                ResultBlock(@"Success",0);
            }
        }else{
            if(ResultBlock){
                ResultBlock(result,1);
            }
        }
    }];
    
}

// 转人工自定义
+ (void)connectCustomerService:(NSString *)groupId  Obj:(id)obj KitInfo:(ZCKitInfo*)uiInfo ZCTurnType:(NSInteger)turnType Keyword:(NSString*)keyword KeywordId:(NSString*)keywordId {
    [[ZCUICore getUICore] customTurnServiceWithGroupId:groupId Obj:obj KitInfo:uiInfo ZCTurnType:turnType Keyword:keyword KeywordId:keywordId];
}

+(void)getLastLeaveReplyMessage:(NSString *)partnerid resultBlock:(void (^)(NSDictionary * , NSMutableArray * , int))ResultBlock{
    if(zcLibConvertToString(partnerid).length == 0){
        partnerid = [ZCSobotApi getUserUUID];
    }
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:zcLibConvertToString([ZCSobotApi getCommanyId]) forKey:@"companyId"];
    [params setObject:zcLibConvertToString(partnerid) forKey:@"partnerId"];
    [[[ZCUICore getUICore] getAPIServer] getLastReplyLeaveMessage:params start:^{
        
    } success:^(NSDictionary *dict, NSMutableArray *itemArray, ZCNetWorkCode sendCode) {
        ResultBlock(dict,itemArray,(int)sendCode);
        
    } failed:^(NSString *errorMessage, ZCNetWorkCode errorCode) {
        ResultBlock(nil,nil,(int)errorCode);
    }];
}

+(void)postLocalNotification:(NSString *)message dict:(NSDictionary *)userInfo{
    [[ZCIMChat getZCIMChat] postLocalNotification:message dict:userInfo];
}

// 获取 SDK 版本号
+ (NSString *)getVersion {
   return  zcGetSDKVersion();
}

// 获取渠道信息
+ (NSString *)getChannel {
   return zcGetAppChannel();
}

// 显示日志信息 默认不显示
+ (void)setShowDebug:(BOOL)isShowDebug {
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",isShowDebug] forKey:ZCKey_ISDEBUG];
}


+(void)setAutoMatchTimeZone:(BOOL)autoMatchTimeZone{
    [ZCLocalStore addObject:[NSString stringWithFormat:@"%d",autoMatchTimeZone] forKey:ZCLOCALAUTO_MATCHTIMEZONE];
}


+(BOOL)getPlatformIsArtificialWithAppkey:(NSString *)appkey Uid:(NSString*)uid{
    
    if ([appkey isEqualToString:[ZCUICore getUICore].getLibConfig.app_key] && [uid isEqualToString:[ZCUICore getUICore].getLibConfig.uid]) {
        if ([ZCUICore getUICore].getLibConfig.isArtificial) {
            return YES;
        }
    }
    return NO;
}

//
+ (NSString *)getSystem {
   return zcGetSystemVersion();
}

// 获取当前app的版本号
+ (NSString *)getAppVersion {
   return zcGetAppVersion();
}

// 获取手机型号
+ (NSString *)getIPhoneType {
   return zcGetIphoneType();
}

// 获取当前集成的app名称
+ (NSString *)getAppName {
   return zcGetAppName();
}

// 获取用户的 UUID
+ (NSString *)getUserUUID {
    
    return [[UIDeviceTools shareDeviceTools] getIOSUUID];
}

// 添加异常统计
+ (void)setZCLibUncaughtExceptionHandler {
    [ZCLibClient setZCLibUncaughtExceptionHandler];
}

// 读取日志文件内容 保存最近的7天
+ (NSString *)readLogFileDateString:(NSString *) dateString {
    return [ZCLibClient readLogFileDateString:dateString];
}

+ (void)outCurrentUserZCLibInfo:(BOOL) isClosePush {
    [ZCLibClient closeAndoutZCServer:isClosePush];
}


// 获取最后一条消息
+ (NSString *)readLastMessage {
    return [[ZCLibClient getZCLibClient] getLastMessage];
}

+(void) getLastMessageInfo:(void (^)(ZCPlatformInfo * _Nonnull, ZCLibMessage * _Nonnull, int))resultBlock{
    
    ZCPlatformInfo *info1 = [[ZCPlatformTools sharedInstance] getPlatformInfo];
    
    if(resultBlock){
        resultBlock(info1,nil,0);
    }
    
    // 去初始化
    [self synchronizationInitInfoToSDK:^(NSString * _Nonnull msg, int code) {
        if(code == 0){
            ZCPlatformInfo *info = [[ZCPlatformTools sharedInstance] getPlatformInfo];

            [[ZCLibServer getLibServer] getChatUserCids:0 config:info.config start:^{
                
            } success:^(NSDictionary *dict, ZCNetWorkCode sendCode) {
        //                _isCidLoading = YES;
                if(dict[@"data"] == nil){
                    if(resultBlock){
                        resultBlock(info,nil,-3);
                    }
                    return;
                }
                NSArray *arr = dict[@"data"][@"cids"];
                
                if(arr !=nil && [arr isKindOfClass:[NSArray class]]  && arr.count > 0){
                    [self getLastHistoryMessage:[NSMutableArray arrayWithArray:arr] info:info blcok:resultBlock];
                }else if (!zcLibIs_null(arr) && arr.count == 0){
                    if(resultBlock){
                        resultBlock(info,nil,-3);
                    }
                }
            } failed:^(NSString *errorMessage, ZCNetWorkCode errorCode) {
                if(resultBlock){
                    resultBlock(info,nil,-2);
                }
            }];
        }
    }];
}

+(void)getLastHistoryMessage:(NSMutableArray *) cids info:(ZCPlatformInfo *) info blcok:(void (^)(ZCPlatformInfo * _Nonnull, ZCLibMessage * _Nonnull, int))resultBlock{
    [[ZCLibServer getLibServer] getHistoryMessages:[cids lastObject] withUid: (info.config.uid) start:^{
        
    } success:^(NSMutableArray *messages, ZCNetWorkCode sendCode) {
        if(resultBlock){
            if(messages.count > 0){
                ZCLibMessage *lastModel = [messages lastObject];
                if(lastModel){

                    info.lastMsg = lastModel.richModel.msg;
                    if(lastModel.richModel.msgType == ZCMessageTypeCard){
                        info.lastMsg = [NSString stringWithFormat:@"[%@]", ZCSTLocalString(@"商品")];
                    }
                    if(lastModel.richModel.msgType == ZCMessageTypeOrder){
                        info.lastMsg = [NSString stringWithFormat:@"[%@]", ZCSTLocalString(@"订单")];
                    }
                    if(lastModel.richModel.msgType == ZCMessageTypeFile){
                        info.lastMsg = [NSString stringWithFormat:@"[%@]", ZCSTLocalString(@"文件")];
                    }
                    if(lastModel.richModel.msgType == ZCMessageTypeVideo){
                        info.lastMsg = [NSString stringWithFormat:@"[%@]", ZCSTLocalString(@"视频")];
                    }
                    if(lastModel.richModel.msgType == ZCMessageTypeSound){
                        info.lastMsg = [NSString stringWithFormat:@"[%@]", ZCSTLocalString(@"声音")];
                    }
                    if(lastModel.richModel.msgType == ZCMessageTypePhoto){
                        info.lastMsg = [NSString stringWithFormat:@"[%@]", ZCSTLocalString(@"图片")];
                    }
                    info.lastDate = lastModel.ts;
                    info.avatar = lastModel.senderFace;
                    info.platformName = lastModel.senderName;
                }
                resultBlock(info,lastModel,1);
            }else{
                [cids removeLastObject];
                if(cids.count > 0){
                    [self getLastHistoryMessage:cids info:info blcok:resultBlock];
                }else{
                    if(resultBlock){
                        resultBlock(info,nil,-4);
                    }
                }
            }
        }
        
    } failed:^(NSString *errorMessage, ZCNetWorkCode errorCode) {
        if(resultBlock){
            resultBlock(info,nil,-1);
        }
    }];
}

// 检查当前消息通道是否建立，没有就重新建立
+ (void)checkIMConnected {
    [[ZCLibClient getZCLibClient] checkIMConnected];
}

// 关闭当前消息通道，使其不再接受消息
+ (void)closeIMConnection {
    [[ZCLibClient getZCLibClient] closeIMConnection];

}

// 清空用户下的所有未读消息(本地清空)
+ (void)clearUnReadNumber:(NSString *) partnerid {
    [[ZCLibClient getZCLibClient] clearUnReadNumber:partnerid];

}

// 获取未读消息数
+ (int)getUnReadMessage {
   return [[ZCLibClient getZCLibClient] getUnReadMessage];

}
+ (NSString *)getLastMessage {
   return [[ZCLibClient getZCLibClient] getLastMessage];

}

#pragma mark - Private method
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


+(void)backgroundInitSDK:(void (^)(NSString *,int code))ResultBlock{
    if ([@"" isEqualToString:zcLibConvertToString([ZCLibClient getZCLibClient].libInitInfo.app_key)] && [@"" isEqualToString:zcLibConvertToString([ZCLibClient getZCLibClient].libInitInfo.customer_code)]) {
        if(ResultBlock){
            ResultBlock(@"appkey不能为空",1);
        }
        return;
    }
    ZCKitInfo *kitInfo = [ZCUICore getUICore].kitInfo;
    if (!kitInfo) {
        kitInfo = [ZCKitInfo new];
    }
    
    
    [[ZCUICore getUICore] openSDKWith:[ZCLibClient getZCLibClient].libInitInfo uiInfo:kitInfo Delegate:nil blcok:^(ZCInitStatus code, NSMutableArray *arr, NSString *result) {
        if(code == ZCInitStatusLoadSuc){
            if(ResultBlock){
                ResultBlock(@"Success",0);
            }
        }else{
            if(ResultBlock){
                ResultBlock(result,1);
            }
        }
    }];
}


+(void)synchronizeLanguage:(NSString *) language write:(BOOL) isReWrite result:(nonnull void (^)(NSString * _Nonnull message, int code))ResultBlock{
    if(zcLibConvertToString(language).length == 0){
        return;
    }
    
    // 本地文件无需同步
    NSString * bundlePath = [[NSBundle mainBundle] pathForResource:@"SobotKit" ofType:@"bundle"];
    bundlePath = [bundlePath stringByAppendingPathComponent:[NSString stringWithFormat:@"SobotLocalizable/%@", language]];
    // 本地bundle中存在文件，则不加载
    if([NSBundle bundleWithPath:bundlePath]){
        if(ResultBlock){
            ResultBlock(@"已存在，未同步",0);
        }
        return;
    }
    NSString *dataPath = zcLibGetDocumentsFilePath([NSString stringWithFormat:@"/sobot/"]);
    // 创建目录
    zcLibCheckPathAndCreate(dataPath);
    // 拼接完整的地址
    dataPath=[dataPath stringByAppendingString:[NSString stringWithFormat:@"/ios_%@_%@.json",zcGetSDKVersion(),language]];
    
    // 文件已经存在，并且不重写
    if(zcLibCheckFileIsExsis(dataPath) && !isReWrite){
        if(ResultBlock){
            ResultBlock(@"已下载，未同步",0);
        }
        return;
    }
    
    NSString *serverUrl = [NSString stringWithFormat:@"https://img.sobot.com/mobile/multilingual/ios/ios_%@_%@.json",[zcGetSDKVersion() substringToIndex:5],language];
    NSLog(@"%@",serverUrl);
    // 下载，播放网络声音
//    https://img.sobot.com/mobile/multilingual/ios/ios_2.8.6_en_lproj.json
//    https://img.sobot.com/mobile/multilingual/ios/ios_2.8.6_en_proj.json
    [[ZCLibServer getLibServer] downFileWithURL:serverUrl start:^{
        
    } success:^(NSData *data) {
        if(data && data.length > 500){
            [data writeToFile:dataPath atomically:YES];
//            NSLog(@"%@",dataPath);
//            NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);

            if(ResultBlock){
                ResultBlock(@"同步成功",0);
            }
        }else{
            if(ResultBlock){
                ResultBlock(@"同步失败，下载不完整",1);
            }
        }
    } progress:^(float progress) {
        
    } fail:^(ZCNetWorkCode errorCode) {
        // 格式不对，不会执行正确的接口
//        if(ResultBlock){
//            ResultBlock(@"同步失败，下载异常",1);
//        }
    }];
}

+(NSString *)getCurLanguagePreHeader{
    return [NSString stringWithFormat:@"%@_lproj",zcGetLanguagePrefix()];
}


// 多语言测试方法
+(NSString *)checkZCSTLocalString:(NSString *)key{
    NSString *v = nil;
    NSString * sourcePath = @"";
    NSString * bundlePath = [[NSBundle mainBundle] pathForResource:@"SobotKit" ofType:@"bundle"];
    bundlePath = [bundlePath stringByAppendingPathComponent:@"SobotLocalizable"];
    
    if([ZCLibClient getZCLibClient].libInitInfo!=nil && [ZCLibClient getZCLibClient].libInitInfo.absolute_language!=nil){
        sourcePath = [bundlePath stringByAppendingPathComponent:[ZCLibClient getZCLibClient].libInitInfo.absolute_language];
        if(![NSBundle bundleWithPath:sourcePath]){
            sourcePath = @"";
            NSString *jsonPath = zcLibGetDocumentsFilePath([NSString stringWithFormat:@"/sobot/ios_%@_%@.json",zcGetSDKVersion(),[ZCLibClient getZCLibClient].libInitInfo.absolute_language]);
            if(zcLibCheckFileIsExsis(jsonPath)){
               NSData *data=[NSData dataWithContentsOfFile:jsonPath];
               NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
               if(dict && [[dict allKeys] containsObject:key]){
                   v = dict[key];
               }
            }
        }
    }
    if(v==nil && sourcePath.length == 0){
        // 跟随系统
        sourcePath = [bundlePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_lproj",zcGetLanguagePrefix()]];
        if(![NSBundle bundleWithPath:sourcePath]){
            // 跟随系统不识别，默认
            if([ZCLibClient getZCLibClient].libInitInfo!=nil && [ZCLibClient getZCLibClient].libInitInfo.default_language!=nil){
                sourcePath = [bundlePath stringByAppendingPathComponent:[ZCLibClient getZCLibClient].libInitInfo.default_language];
            }else{
                sourcePath = [bundlePath stringByAppendingPathComponent:@"en_lproj"];
            }
        }
    }
    if(sourcePath.length > 0){
        NSBundle *resourceBundle = [NSBundle bundleWithPath:sourcePath];
        v = [resourceBundle localizedStringForKey:key value:@"" table:@"SobotLocalizable"];
    }
    return v==nil ? key : v;
}


@end
