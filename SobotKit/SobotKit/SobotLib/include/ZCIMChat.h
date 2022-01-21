//
//  ZCIMChat.h
//  SobotApp
//
//  Created by zhangxy on 16/7/4.
//  Copyright © 2016年 com.sobot.chat.app. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZCLibConfig.h"
#import "ZCLibStatusDefine.h"
#import "ZCLibNetworkTools.h"
#import "ZCLibMessageConstants.h"


typedef NS_ENUM(NSInteger,ZCChatPageState) {
    ZCChatPageStateActive = 1,
    ZCChatPageStateBack  = 2,
};

typedef NS_ENUM(NSInteger,ZCSendMessageType) {
    ZCSendMessagePhoto = 1,
    ZCSendMessageText  = 2,
    ZCSendMessageVoice = 3,
};

typedef NS_ENUM(NSInteger,ZCSendActionType) {
    ZCActionConnect   = 0,  // 连接认证
    ZCActionheartbeat = 1,  // 心跳
    ZCActionConfim    = 2,  // 消息确认
    ZCActionBusiness  = 3,  // 业务
};


@interface ZCIMChat : NSObject

// 初始化成功返回的对象
@property(nonatomic,strong) NSMutableArray       *wslinkbak;

// 接收消息回调
@property(nonatomic,weak) id<ZCMessageDelegate>  delegate;



/**
 获取连接对象

 @return
 */
+(ZCIMChat *)getZCIMChat;


/**
 *  创建链接
 */
-(void)onConnection:(NSString *) ipWithPort;


/**
 检查当前是否已经连接成功，没有主动重连  isBecomeActive 是否应用回到前台
 */
-(void)checkConnected:(BOOL)isBecomeActive;

    
/**
 启动轮询

 @param isOnlyType 是否唯一指定方式
 */
-(void)startLoopRequest:(BOOL) isOnlyType;


/**
 当前连接状态

 @return
 */
-(BOOL) isConnected;


/**
 *  关闭连接
 */
-(void)closeConnection;



/**
 移除所有监听
 */
-(void) removeAllObserver;


/**
 新增所有监听
 */
-(void)checkObserverAndAdd;

/**
 *  销毁长连接
 isEnterBackground 是否程序进入后台 YES程序进入后台，只关闭通道，不清理存储数据 。 NO 关闭消息通道，清理存储数据。
 */
-(void)destoryIMChat:(BOOL)isEnterBackground;


/**
 设置当前是否在聊天页面，统计未读消息

 @param isBack YES，退出聊天页面，开始计数，NO进入聊天页面，清除消息数
 */
-(void)setChatPageState:(ZCChatPageState) state;


/**
 获取未读消息数

 @return
 */
-(int) getUnReadNum;



/// 发送本地推送
/// @param message 发送本地提醒
-(void)postLocalNotification:(NSString *)message dict:(NSDictionary *) userInfo;

/**
 长时间不说话离线通知

 @param isServer 是否为服务端下推消息(例外:转人工/给机器人发消息/获取技能组)
 */
-(void)userOfflineByLongTimeIsServer:(BOOL )isServer config:(ZCLibConfig *) _libConfig appkey:(NSString *) appkey;
//-(void)userOfflineByLongTimeIsServer:(BOOL )isServer;


///////////////////////////////////////////////////////////
// 上传日志
-(void)uploadLogMsg;
-(void)uploadLogMsg:(BOOL) updateWithOutFlag;

@end
