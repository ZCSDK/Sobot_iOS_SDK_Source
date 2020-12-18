//
//  ZCAddressModel.m
//  SobotKit
//
//  Created by lizhihui on 2018/1/5.
//  Copyright © 2018年 zhichi. All rights reserved.
//

#import "ZCAddressModel.h"
#import "ZCLibCommon.h"
@implementation ZCAddressModel

-(id)initWithMyDict:(NSDictionary *)dict{
    if (self = [super init]) {
        
       _provinceId = zcLibConvertToString(dict[@"provinceId"]);
        
       _provinceName = zcLibConvertToString(dict[@"provinceName"]);
        
       _cityId = zcLibConvertToString(dict[@"cityId"]);
        
       _cityName = zcLibConvertToString(dict[@"cityName"]);
        
       _areaId = zcLibConvertToString(dict[@"areaId"]);
        
       _areaName = zcLibConvertToString(dict[@"areaName"]);
        
       _endFlag = [zcLibConvertToString(dict[@"endFlag"]) intValue];
    }
    return self;
}


@end
