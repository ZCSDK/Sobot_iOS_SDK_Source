//
//  ZCStoreConfiguration.m
//  SobotKit
//
//  Created by zhangxy on 2017/2/14.
//  Copyright © 2017年 zhichi. All rights reserved.
//

#import "ZCStoreConfiguration.h"

NSString * const KEY_ZCCONFIGMESSAGE           = @"KEYP_ZCConfigMessage";

NSString * const KEY_ZCISROBOTHELLO            = @"KEYP_ZCisRobotHello";

NSString * const KEY_ZCISEVALUATIONSERVICE     = @"KEYP_ZCIsEvaluationService";

NSString * const KEY_ZCISEVALUATIONROBOT       = @"KEYP_ZCisEvaluationRobot";

// 包含 cid/time/out_time
//NSDictionary *lastChat = @{@"cid":sobotConvertToString([self getZCIMConfig].cid),
//                           @"time":sobotDateTransformString(SOBOT_FORMATE_DATETIME,[NSDate now]),
//                           @"out_time":[NSString stringWithFormat:@"%d",[self getZCIMConfig].userOutTime]
//};
NSString * const KEY_ZCLASTCHAT       = @"KEYP_ZCLastChat";

@implementation ZCStoreConfiguration

+(void)setZCParamter:(NSString *)key value:(id)value{
    [ZCLocalStore addObject:value forKey:key];
}

+(id)getZCObjectValue:(NSString *)key{
    return [ZCLocalStore getLocalParamter:key];
}

+(NSString *)getZCParamter:(NSString *) key{
    return sobotConvertToString([ZCLocalStore getLocalParamter:key]);
}

+(int)getZCIntParamter:(NSString *) key{
    return [sobotConvertToString([ZCLocalStore getLocalParamter:key]) intValue];
}

+(void)removeZCParamter:(NSString *) key{
    [ZCLocalStore removeObjectByKey:key];
}


+(void)cleanLocalParamter{
    //清理个人信息缓存
    NSUserDefaults *userDefatluts = [NSUserDefaults standardUserDefaults];
    NSDictionary *dictionary = [userDefatluts dictionaryRepresentation];
    if(dictionary.allKeys.count>0){
        for(NSString* key in [dictionary allKeys]){
            if([key hasPrefix:@"KEYP_ZC"]){
                [userDefatluts removeObjectForKey:key];
            }
        }
        
        [userDefatluts synchronize];
    }
}

@end
