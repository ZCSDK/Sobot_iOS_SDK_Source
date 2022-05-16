//
//  ZCMsgDetailsVC.h
//  SobotKit
//
//  Created by lizhihui on 2019/2/20.
//  Copyright © 2019 zhichi. All rights reserved.
//

#import <SobotKit/SobotKit.h>
#import "ZCRecordListModel.h"
#import "ZCUILeaveMessageController.h"
NS_ASSUME_NONNULL_BEGIN

@interface ZCMsgDetailsVC : ZCUIBaseController

@property (nonatomic,copy) NSString * ticketId; // 工单id
@property (nonatomic,copy) NSString * companyId; // 工单id
@property (nonatomic,strong) ZCUILeaveMessageController *leaveMsgController;
@end

NS_ASSUME_NONNULL_END
