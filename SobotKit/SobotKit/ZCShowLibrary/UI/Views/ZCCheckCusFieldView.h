//
//  ZCCheckCusFieldView.h
//  SobotKit
//
//  Created by 张新耀 on 2019/9/4.
//  Copyright © 2019 zhichi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZCLibOrderCusFieldsModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZCCheckCusFieldView : UIView

@property (nonatomic,assign) BOOL isPush;

@property(nonatomic,strong) ZCLibOrderCusFieldsModel *preModel;

@property (nonatomic, strong)  void(^orderCusFiledCheckBlock) (ZCLibOrderCusFieldsDetailModel *model,NSMutableArray *arr);

@property(nonatomic,strong) NSMutableArray *listArray;


@end

NS_ASSUME_NONNULL_END
