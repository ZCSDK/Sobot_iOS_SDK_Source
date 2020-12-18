//
//  ZCStoreConfiguration.h
//  SobotKit
//
//  Created by zhangxy on 2017/2/14.
//  Copyright © 2017年 zhichi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZCLocalStore.h"
#import "ZCKitInfo.h"

/** 用户ID 用户的唯一标识 */
extern NSString * const KEY_ZCUSERID;

/** appkey app的标识 */
extern NSString * const KEY_ZCCONFIGMESSAGE;

/** 是否发送过机器人欢迎语 */
extern NSString * const KEY_ZCISROBOTHELLO;

/** 是否评价过人工客服 */
extern NSString * const KEY_ZCISEVALUATIONSERVICE;

/** 是否评价过机器人 */
extern NSString * const KEY_ZCISEVALUATIONROBOT;

// 包含 cid/backtime/timeout
extern NSString * const KEY_ZCLASTCHAT;


@interface ZCStoreConfiguration : NSObject


+(id)getZCObjectValue:(NSString *) key;

+(NSString *)getZCParamter:(NSString *) key;
+(int)getZCIntParamter:(NSString *) key;

+(void)setZCParamter:(NSString *) key value:(id) value;

+(void)removeZCParamter:(NSString *) key;

+(void) cleanLocalParamter;




@end
