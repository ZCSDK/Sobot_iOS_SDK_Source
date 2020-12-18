//
//  CustomActionSheet.h
//  SobotSDK
//
//  Created by 张新耀 on 15/8/5.
//  Copyright (c) 2015年 sobot. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ZCLibConfig.h"

#import "ZCLibSatisfaction.h"

/**
 * RobotChangeTag ENUM
 */
typedef NS_ENUM(NSInteger, RobotChangeTag) {
    /** 已解决 */
    RobotChangeTag1=1,
    /** 未解决 */
    RobotChangeTag2=2,
    /** 暂不评价 */
    RobotChangeTag3=3,
};


typedef NS_ENUM(NSUInteger, SatisfactionType) {
    
    /** 机器人的评价  返回关闭*/
    RobotSatisfcationBackType = 1,
    
    /** 机器人评价（点击底部评价按钮） */
    RobotSatisfcationNolType = 2,
    
    /** 人工客服评价 返回关闭*/
    ServerSatisfcationBackType = 3,
    
    /** 人工客服评价 （点击底部评价按钮）*/
    ServerSatisfcationNolType = 4,
    
    /*** 人工客服主动邀请评价***/
    ServerSatisfcationInviteType = 5,
    
    /**** 留言详情页面 评价本次服务 *****/
    ServerSatisfcationOrderType = 6,
};


typedef NS_ENUM(NSUInteger, ClickType) {
    //已解决
    ClickTypeSolve,
    //未解决
    ClickTypeUnsolved
};



/**
 *  ZCUIBackActionSheetDelegate
 */
@protocol ZCUIBackActionSheetDelegate <NSObject>

@optional
/**
 *  显示“感谢您的反馈”（代理方法）
 *
 *  @param isCommentType  0 不关闭通道，但是返回启动页  1.关闭通道  2.只显示感谢反馈  4，直接关闭页面，退出SDK页面
 *
 *
 */
-(void) actionSheetClick:(int) isCommentType;


-(void) actionSheetClickWithDic:(NSDictionary *)ModelDic;
/**
 *  感谢您的反馈  type 是否客服主动邀请评价 rating 几星  isresolve 是否已解决
 */
- (void)thankFeedBack:(int)type rating:(float)rating IsResolve:(int)isresolve;

//- (void)thankFeedBack;
/**
 *  ZCUIBackActionSheet 不能连续创建 记录当前页面已销毁
 *
 */
-(void)dimissCustomActionSheetPage;
@end

/**
 评价 页面弹出层
 */
@interface ZCUICustomActionSheet : UIView

@property(nonatomic,assign)BOOL isOpenProblemSolving;// 是否开启 已解决 未解决


/**
 *  代理
 */
@property (nonatomic,strong) id<ZCUIBackActionSheetDelegate> delegate;


/**
 *
 *   txtFlag;//评价文本框开关  0 关闭  1 开启 （仅工单详情页面触发评价时使用）
 *
 **/
@property (nonatomic,assign) BOOL  textFlag;

/**
 *
 *  ticketld 工单id 仅工单详情页面触发评价时使用
 *
 **/
@property (nonatomic,copy) NSString * ticketld;

/**
 *
 *  星评 和星评说明   例如 5星： 非常满意
 *
 **/
@property (nonatomic,strong) NSArray * ticketScoreInfooList;


/**
 *  type  当前是机器人还是人工
 *  config  ZCLibConfig
 *  view    将要添加在view上
 *  name  客服或者机器人的昵称
 *  isBack   返回是否关闭页面
 *  invitationType  是否客服主动邀请评价 主动评价 1 邀请评价0
 *  uid        用户ID
 * isCloseAfterEvaluation  评价完人工是否结束会话
 * IsAddServerSatifaction 是否刷新客服主动邀请评价的满意度cell
 */
- (ZCUICustomActionSheet*)initActionSheet:(SatisfactionType)type Name:(NSString *)name Cofig:(ZCLibConfig *)config cView:(UIView *)view  IsBack:(BOOL)isBack isInvitation:(int) invitationType  WithUid:(NSString *)uid  IsCloseAfterEvaluation:(BOOL) isCloseAfterEvaluation  Rating:(int)rating IsResolved:(int)isResolve IsAddServerSatifaction:(BOOL) isAddServerSatifaction;



- (ZCUICustomActionSheet*)initActionSheet:(SatisfactionType)type Name:(NSString *)name Cofig:(ZCLibConfig *)config cView:(UIView *)view  IsBack:(BOOL)isBack isInvitation:(int) invitationType  WithUid:(NSString *)uid  IsCloseAfterEvaluation:(BOOL) isCloseAfterEvaluation  Rating:(int)rating IsResolved:(int)isResolve IsAddServerSatifaction:(BOOL) isAddServerSatifaction txtFlag:(int)txtFlag ticketld:(NSString*)ticketld ticketScoreInfooList:(NSArray*)ticketScoreInfooList;


/**
 *  显示弹出层
 *  @param  view  添加到指定的view
 */
- (void)showInView:(UIView *)view;


/**
 *  关闭弹出层
 */
- (void)tappedCancel;




@end
