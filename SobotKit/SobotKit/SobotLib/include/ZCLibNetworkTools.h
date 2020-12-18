//
//  NetworkTools.h
//  SobotApp
//
//  Created by 张新耀 on 15/9/7.
//  Copyright (c) 2015年 com.sobot.chat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 *  网络连接状态工具类
 */
@interface ZCLibNetworkTools : NSObject

/**
 *  如果没有连接到网络就弹出提醒实况
 */
@property (assign, nonatomic) BOOL isZCReachable;

/**
 *  是否为WIFI
 */
@property (assign, nonatomic) BOOL isZCReachableWiFi;

/**
 *  是否为WLAN
 */
@property (assign, nonatomic) BOOL isZCReachableWLAN;


/**
 *  网络状态
 */
@property (strong, nonatomic) NSString * zcNetWorkStatusString;

/**
 *  单例
 *
 *  @return ZCLibNetworkTools创建的对象
 */
+(ZCLibNetworkTools *) shareNetworkTools;


/**
 *  移除网络监听
 */
-(void)removeNetworkObserver;


@end
