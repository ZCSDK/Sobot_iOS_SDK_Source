//
//  ZCAddressModel.m
//  SobotKit
//
//  Created by lizhihui on 2018/1/5.
//  Copyright © 2018年 zhichi. All rights reserved.
//

#import "ZCAddressModel.h"
#import "SobotUtils.h"
@implementation ZCAddressModel

-(id)initWithMyDict:(NSDictionary *)dict{
    if (self = [super init]) {
        
       _provinceId = sobotConvertToString(dict[@"provinceId"]);
        
       _provinceName = sobotConvertToString(dict[@"provinceName"]);
        
       _cityId = sobotConvertToString(dict[@"cityId"]);
        
       _cityName = sobotConvertToString(dict[@"cityName"]);
        
       _areaId = sobotConvertToString(dict[@"areaId"]);
        
       _areaName = sobotConvertToString(dict[@"areaName"]);
        
       _endFlag = [sobotConvertToString(dict[@"endFlag"]) intValue];
    }
    return self;
}


@end
