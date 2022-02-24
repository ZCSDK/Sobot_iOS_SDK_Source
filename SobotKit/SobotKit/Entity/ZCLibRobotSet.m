//
//  ZCLibRobotSet.m
//  SobotKit
//
//  Created by lizhihui on 2018/5/24.
//  Copyright © 2018年 zhichi. All rights reserved.
//

#import "ZCLibRobotSet.h"
#import "SobotUtils.h"
@implementation ZCLibRobotSet


-(id)initWithMyDict:(NSDictionary *)dict{
    self=[super init];
    if(self){
        @try {
            _robotFlag      = sobotConvertToString(dict[@"robotFlag"]);
            _robotAlias      = sobotConvertToString(dict[@"robotAlias"]);
            _robotName  = sobotConvertToString(dict[@"robotName"]);
            _operationRemark = sobotConvertToString(dict[@"operationRemark"]);
            _guideFlag     = [sobotConvertToString(dict[@"guideFlag"]) boolValue];
            _robotLog     = sobotConvertToString(dict[@"robotLogo"]);
            _robotHelloWord = sobotConvertToString(dict[@"robotHelloWord"]);
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
    }
    return self;
}

@end
