//
//  ZCQuickLeaveView.h
//  SobotKit
// 多轮会话，触发留言，直接弹出留言记录
//  Created by zhangxy on 2022/4/20.
//  Copyright © 2022 zhichi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^ZCQuickLeaveViewBlock)(int code,id obj);


@interface ZCQuickLeaveView : UIView



// 分类的数据，tickeTypeFlag=1时使用
@property (nonnull,strong) UIViewController *exController;

// 2.8.0 是否显示标题
@property (nonatomic , assign) BOOL     ticketTitleShowFlag;

//1-自行选择分类，要显示  2-指定分类 其他，不显示
@property (nonatomic,assign) int tickeTypeFlag;
// 分类的数据，tickeTypeFlag=1时使用
@property (nonnull,strong) NSMutableArray * typeArr;
// 当-指定分类 传这个值
@property (nonatomic,copy) NSString * _Nullable ticketTypeId;

// "'您好，为了更好地解决您的问题,请告诉我们以下内容：<br>1. 您的姓名 2. 问题描述'"
// 输入框自定义提示语
@property (nonatomic,copy) NSString * _Nullable msgTmp;

// 顶部导航提示语
@property (nonatomic,copy) NSString * _Nullable msgTxt;

// {"templateId":1}，模板id从配置列表接口获取
@property (nonatomic,strong) NSDictionary * _Nullable templateldIdDic;

// 是否显示email，是否必填
@property (nonatomic , assign) BOOL     emailFlag;
@property (nonatomic , assign) BOOL     emailShowFlag;


// 2.7.1版本 和留言模板关联 数据从模板接口获取 原初始化接口的数据不在使用
@property (nonatomic , assign) BOOL     telShowFlag;
@property (nonatomic , assign) BOOL     telFlag;

// 是否显示附件，是否必填
@property (nonatomic , assign) BOOL     enclosureShowFlag;
@property (nonatomic , assign) BOOL     enclosureFlag;

// 用户自定义字段数组
@property(nonatomic,strong)NSMutableArray *_Nullable coustomArr;

@property (nonatomic,copy) ZCQuickLeaveViewBlock resultBlock;

-(ZCQuickLeaveView *)initActionSheet:(UIView *)view withController:(UIViewController *)exController;

- (void)showEditView;

- (void)tappedCancel:(BOOL) isClose;
@end

NS_ASSUME_NONNULL_END
