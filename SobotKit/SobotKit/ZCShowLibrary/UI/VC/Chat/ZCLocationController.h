//
//  ZCLocationController.h
//  SobotKit
//
//  Created by zhangxy on 2018/11/30.
//  Copyright © 2018年 zhichi. All rights reserved.
//

// 判断是否有 SobotUserLocation.h头文件，如果有，就使用定位
#define SOBOT_OPENLOCATION 0


#import <SobotKit/SobotKit.h>

#if SOBOT_OPENLOCATION

NS_ASSUME_NONNULL_BEGIN

@interface ZCLocationController : ZCUIBaseController

@property (copy, nonatomic) void (^checkLocationBlock)(NSDictionary *locations);

@end

NS_ASSUME_NONNULL_END

#endif
