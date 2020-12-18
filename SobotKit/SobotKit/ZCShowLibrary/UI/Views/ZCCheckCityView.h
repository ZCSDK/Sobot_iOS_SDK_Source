//
//  ZCCheckCityView.h
//  SobotKit
//
//  Created by 张新耀 on 2019/10/10.
//  Copyright © 2019 zhichi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZCLibTicketTypeModel.h"

#import "ZCAddressModel.h"
#import "ZCUIBaseController.h"
NS_ASSUME_NONNULL_BEGIN

@interface ZCCheckCityView : UIView


@property (nonatomic,assign) int  levle; // 1 省  2 市  3 县 区

@property(nonatomic,weak) NSString *pageTitle;

@property (nonatomic,copy) NSString * proviceId;

@property (nonatomic,copy) NSString * proviceName;

@property (nonatomic,copy) NSString * cityId;

@property (nonatomic,copy) NSString * cityName;

@property (nonatomic,copy) NSString * areaId;

@property (nonatomic,copy) NSString * areaName;


@property(nonatomic,weak) UIView *parentView;


@property (nonatomic, strong)  void(^orderTypeCheckBlock) (ZCAddressModel *model);

@property(nonatomic,strong)NSMutableArray   *listArray;

@end

NS_ASSUME_NONNULL_END
