//
//  ZCLibRobotSet.h
//  SobotKit
//
//  Created by lizhihui on 2018/5/24.
//  Copyright © 2018年 zhichi. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *
 *  多机器人切换业务
 *
 **/
@interface ZCLibRobotSet : NSObject

@property (nonatomic,copy) NSString  *robotFlag;
@property (nonatomic,copy) NSString  *robotAlias;

@property (nonatomic,copy) NSString  *robotName;

@property (nonatomic,assign) BOOL      guideFlag; //机器人引导语开关

@property (nonatomic,copy) NSString * operationRemark; // 业务介绍

@property (nonatomic,copy) NSString * robotLog;// 机器人头像

@property (nonatomic,copy) NSString * robotHelloWord;// 机器人欢迎语

-(id)initWithMyDict:(NSDictionary *)dict;
@end
