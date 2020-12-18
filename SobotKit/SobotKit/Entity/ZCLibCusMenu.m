//
//  ZCLibCusMenu.m
//  SobotKit
//
//  Created by lizhihui on 2018/5/25.
//  Copyright © 2018年 zhichi. All rights reserved.
//

#import "ZCLibCusMenu.h"
#import "ZCLibCommon.h"
@implementation ZCLibCusMenu

-(id)initWithMyDict:(NSDictionary *)dict{
    self=[super init];
    if(self){
        @try {
            _title      = zcLibConvertToString(dict[@"lableName"]);
            _url  = zcLibConvertToString(dict[@"lableLink"]);
            _lableId = [zcLibConvertToString(dict[@"lableId"]) integerValue];
            _imgName = zcLibConvertToString(dict[@"imgName"]);
            _imgNamePress = zcLibConvertToString(dict[@"imgNamePress"]);
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
    }
    return self;
}

@end
