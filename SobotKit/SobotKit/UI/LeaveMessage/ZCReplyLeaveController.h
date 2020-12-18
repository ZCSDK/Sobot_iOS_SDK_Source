//
//  ZCReplyLeaveController.h
//  SobotKit
//
//  Created by 张新耀 on 2019/12/3.
//  Copyright © 2019 zhichi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SobotKit.h"

typedef void(^ReplyLeaveBlock)(int code,NSString * _Nonnull replyResult);

NS_ASSUME_NONNULL_BEGIN

@interface ZCReplyLeaveController : ZCUIBaseController


@property (nonatomic,copy) NSString *ticketId;
@property (nonatomic,copy) ReplyLeaveBlock  passMsgBlock;


@end

NS_ASSUME_NONNULL_END
