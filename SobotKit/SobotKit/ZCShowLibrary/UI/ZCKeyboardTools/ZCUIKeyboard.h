//
//  ZCUIKeyboard.h
//  SobotKit
//
//  Created by zhangxy on 15/11/13.
//  Copyright © 2015年 zhichi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZCLibConfig.h"
#import "ZCButton.h"
#import "EmojiBoardView.h"
#import "ZCUIRecordView.h"
#define BottomHeight 49

#define ZCConnectBottomHeight 104

#import "ZCLibMessageConstants.h"

//#import "ZCTextView.h"

typedef  void(^ScrollTableToBottomBlock)(void);

/**ZCKeyboardType键盘类型*/
typedef NS_ENUM(NSInteger,ZCKeyboardClickType) {
    /** 执行转接人工 */
    ZCKeyboardClickTypeTurnUser            = 1,
    /** 执行转接人工 */
    ZCKeyboardClickTypeReConnectedUser     = 2,
    /** 执行重新初始化 */
    ZCKeyboardClickTypeReInit              = 3,
    /** 去留言 */
    ZCKeyboardClickTypeLeavePage           = 4,
    /** 关闭技能组选择框 */
    ZCKeyboardClickTypeCloseSkillSet       = 5,
    /** 满意度评价 */
    ZCKeyboardClickTypeSatisfaction        = 6,
    /** 添加留言tipCell */
    ZCKeyboardClickTypeAddLeavemeg         = 7,
    /** 排队中重复点击转人工操作 */
    ZCKeyboardClickTypeDoWaiteWarning      = 8,
    /** 仅机器人模式添加机器人欢迎语 */
    ZCKeyboardClickTypeAddRobotHelloWolrd  = 9,
    /** 添加拉黑tipCell */
    ZCKeyboardClickTypeAddBlockTipCell     = 10,
    /** 用户离线不能发送消息，提醒本次会话已结束 */
    ZCKeyboardClickTypeAddOverMsgTipCell   = 11,
    // 相机
    ZCKeyboardClickTypeAddPhotoCamera      = 12,
    // 相册
    ZCKeyboardClickTypeAddPhotoPicture     = 13,
    
    // 添加文件
    ZCKeyboardClickTypeAddDocumentFile     = 14,
    
    // 添加位置
    ZCKeyboardClickTypeAddLocation     = 15
    
};

/**
 *   ZCKeyboardStatus   ENUM
 */
typedef NS_ENUM(NSUInteger,ZCKeyboardViewStatus){
    ZCKeyboardStatusWaiting        = 3,           // 转人工、+ 、输入框、排队中...
    ZCKeyboardStatusUser           = 10,          // 人工键盘样式
    ZCKeyboardStatusRobot          = 11,          // 机器人键盘样式
    ZCKeyboardStatusNewSession     = 12,          // 新会话键盘样式
};


/**
 *  智齿 底部bottomView
 *  输入框 转人工按钮 语音按钮 相机相册按钮
 */
@interface ZCUIKeyboard : NSObject

// 导航栏是否影藏
@property (nonatomic,assign) BOOL isNavcHide;

// 系统导航栏的透明度
@property (nonatomic,assign) BOOL isTranslucent;

/** 初始化时 能否点击转人工按钮 */
@property (nonatomic,assign) BOOL   isConnectioning;

/** 聊天页底部View（输入框，按钮的父类） */
@property (nonatomic,strong) UIView     *zc_bottomView;

/** 输入框 */
@property (nonatomic,strong) UITextView *zc_chatTextView;

/** 转人工按钮 */
@property (nonatomic,strong) UIButton   *zc_turnButton;

/** 录音按钮 */
@property (nonatomic,strong) UIButton   *zc_pressedButton;


/** 获取用户传入的VC页面 */
@property (nonatomic,strong) UIView *zc_sourceView;

// 2.8.0
@property (nonatomic,strong) UIView * verticalLineView;

// 2.8.3 当前屏幕方向  2 为横屏，刘海向左
@property (nonatomic,assign) NSInteger curScreenDirection;

/**
 *  初始化聊天页面中的底部输入框区域UI
 *
 *  @param unitView  聊天VC的View
 *  @param listTable 聊天的tableview
 *  @param delegate  代理
 *
 */
-(id)initConfigView:(UIView *)unitView table:(UITableView *)listTable;

/**
 *  通过初始化信息设置键盘以及相应的操作
 *
 *  @param config 配置信息model
 */
-(void)setInitConfig:(ZCLibConfig *)config;

/**
 *  添加键盘监听
 */
- (void)handleKeyboard;

/**
 *  隐藏键盘
 */
-(void)hideKeyboard;

/**
 *  移除键盘监听
 */
-(void)removeKeyboardObserver;



-(void)setKeyBoardStatus:(ZCKeyboardViewStatus)status;

/**
 设置状态栏高度

 @param height
 */
-(void)setZCChatNavHeight:(CGFloat) height;

-(void)setTableStartY:(CGFloat ) height;


/**
 *  获取当前键盘的样式
 */
-(ZCKeyboardViewStatus) getKeyBoardViewStatus;

-(CGFloat) getKeyboardHeight;

@property (nonatomic,copy) ScrollTableToBottomBlock  scrollTableToBottomBlock;

// 暗黑模式切换是，重新加载图片
-(void)reloadImages;

@end
