//
//  ZCAddressModel.h
//  SobotKit
//
//  Created by lizhihui on 2018/1/5.
//  Copyright © 2018年 zhichi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZCAddressModel : NSObject

@property (nonatomic,copy) NSString * provinceId;

@property (nonatomic,copy) NSString * provinceName;

@property (nonatomic,copy) NSString * cityId;

@property (nonatomic,copy) NSString * cityName;

@property (nonatomic,copy) NSString * areaId;

@property (nonatomic,copy) NSString * areaName;

@property (nonatomic,assign) int endFlag;

-(id)initWithMyDict:(NSDictionary *)dict;

@end
