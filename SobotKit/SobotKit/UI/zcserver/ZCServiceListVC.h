//
//  ZCServiceListVC.h
//  SobotKit
//
//  Created by lizhihui on 2019/3/28.
//  Copyright © 2019 zhichi. All rights reserved.
//

#import <SobotKit/SobotKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZCServiceListVC : ZCUIBaseController

@property (nonatomic,copy) NSString * titleName; // 标题

@property (nonatomic,copy) NSString * categoryId;// 分类id

@property (nonatomic,copy) NSString * appId;


@property(nonatomic,strong) void (^OpenZCSDKTypeBlock)(ZCUIBaseController *object);

@property (nonatomic,strong) ZCKitInfo * kitInfo;

@end

NS_ASSUME_NONNULL_END
