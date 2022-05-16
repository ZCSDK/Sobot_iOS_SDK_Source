//
//  ZCSelLeaveView.h
//  SobotKit
//
//  Created by lizhihui on 2019/2/19.
//  Copyright © 2019 zhichi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZCWsTemplateModel.h"


NS_ASSUME_NONNULL_BEGIN

typedef void(^SelLeaveClickBlock)(ZCWsTemplateModel * itemModel );

@interface ZCSelLeaveView : UIView

@property (nonatomic,copy) SelLeaveClickBlock msgSetClickBlock;

-(ZCSelLeaveView*)initActionSheet:(NSMutableArray *)array WithView:(UIView *)view MsgID:(int)msgId IsExist:(NSInteger) isExist;

- (void)showInView:(UIView *)view;

- (void)tappedCancel:(BOOL) isClose;

@end

NS_ASSUME_NONNULL_END
