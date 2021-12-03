//
//  ZCLeaveMsgVC.h
//  SobotKit
//
//  Created by lizhihui on 2019/4/3.
//  Copyright © 2019 zhichi. All rights reserved.
//

#import <SobotKit/SobotKit.h>

typedef void(^PassMsgBlock)(NSString *msg);

NS_ASSUME_NONNULL_BEGIN


/// 留言转离线消息
@interface ZCLeaveMsgVC : ZCUIBaseController

@property (nonatomic,copy) NSString *msgTmp;// "'您好，为了更好地解决您的问题,请告诉我们以下内容：<br>1. 您的姓名 2. 问题描述'"


/// 是否开启敏感词
@property (nonatomic,copy) NSString *leaveExplain;

@property (nonatomic,copy) NSString *msgTxt;// "<p>您好，很抱歉我们暂时无法为您提供服务，如需帮助，请留言，我们将尽快联系并解决您的问题</p>"

@property (nonatomic,copy) PassMsgBlock  passMsgBlock;

@property (nonatomic,copy) NSString *groupId;// 技能组ID
@end

NS_ASSUME_NONNULL_END
