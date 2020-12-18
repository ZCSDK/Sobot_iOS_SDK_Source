//
//  ZCLibRobotSet.m
//  SobotKit
//
//  Created by lizhihui on 2018/5/24.
//  Copyright © 2018年 zhichi. All rights reserved.
//

#import "ZCLibRobotSet.h"
#import "ZCLibCommon.h"
@implementation ZCLibRobotSet


-(id)initWithMyDict:(NSDictionary *)dict{
    self=[super init];
    if(self){
        @try {
            _robotFlag      = zcLibConvertToString(dict[@"robotFlag"]);
            _robotAlias      = zcLibConvertToString(dict[@"robotAlias"]);
            _robotName  = zcLibConvertToString(dict[@"robotName"]);
            _operationRemark = zcLibConvertToString(dict[@"operationRemark"]);
            _guideFlag     = [zcLibConvertToString(dict[@"guideFlag"]) boolValue];
            _robotLog     = zcLibConvertToString(dict[@"robotLogo"]);
            _robotHelloWord = zcLibConvertToString(dict[@"robotHelloWord"]);
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
    }
    return self;
}

@end
