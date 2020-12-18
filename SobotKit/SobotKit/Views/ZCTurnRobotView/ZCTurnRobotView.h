//
//  ZCTurnRobotView.h
//  SobotKit
//
//  Created by lizhihui on 2018/5/24.
//  Copyright © 2018年 zhichi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZCLibRobotSet.h"
typedef void(^TurnRobotSetClickBlock)(ZCLibRobotSet * itemModel);

@interface ZCTurnRobotView : UIView

-(ZCTurnRobotView*)initActionSheet:(NSMutableArray *)array WithView:(UIView *)view RobotId:(int)robotId;

- (void)showInView:(UIView *)view;

- (void)tappedCancel:(BOOL) isClose;

@property (nonatomic,copy) TurnRobotSetClickBlock robotSetClickBlock;

@end
