//
//  ZCCheckMulCusFieldView.h
//  SobotKit
//
//  Created by zhangxy on 2022/5/23.
//  Copyright © 2022 zhichi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZCLibOrderCusFieldsModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZCCheckMulCusFieldView : UIView

@property(nonatomic,strong)NSMutableArray   *showArray;
@property(nonatomic,strong)NSMutableArray   *allArray;

@property(nonatomic,weak) NSString *pageTitle;

@property(nonatomic,weak) UIView *parentView;
@property(nonatomic,strong) NSString *parentDataId;

@property(nonatomic,strong) ZCLibOrderCusFieldsModel *preModel;

@property (nonatomic, strong)  void(^orderCusFiledCheckBlock) (ZCLibOrderCusFieldsDetailModel *model,NSString *dataIds,NSString *dataNames);

@property (nonatomic, strong)  void(^ChangePageBlock) (int type,CGFloat height);

@end

NS_ASSUME_NONNULL_END
