//
//  ZCMsgRecordVC.h
//  SobotKit
//
//  Created by lizhihui on 2019/2/19.
//  Copyright © 2019 zhichi. All rights reserved.
//

#import <SobotKit/SobotKit.h>
#import "ZCRecordListModel.h"

typedef void(^JumpMsgDetailVCBlock)(ZCRecordListModel* model);

NS_ASSUME_NONNULL_BEGIN

/// 留言记录列表
@interface ZCMsgRecordVC : ZCUIBaseController

@property (nonatomic,copy) JumpMsgDetailVCBlock  jumpMsgDetailBlock;
-(void)updataWithHeight:(CGFloat)height viewWidth:(CGFloat)w;

-(void)loadData;// 刷新数据

@end

NS_ASSUME_NONNULL_END
