//
//  ZCChatBaseCell.h
//  SobotApp
//
//  Created by 张新耀 on 15/9/15.
//  Copyright (c) 2015年 com.sobot.chat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZCLibMessage.h"
#import "ZCLibConfig.h"
#import "ZCChatCellDelegate.h"
//#import "ZCUIImageView.h"
#import "ZCMLEmojiLabel.h"
#import "ZCHtmlFilter.h"
#import "ZCHtmlCore.h"
#import "SobotImageView.h"

#define ImageHeight 175
#define Spaceheight 2
#define SpaceRX 12
#define SpaceLX 12
#define GetCellItemX(isRight) isRight?SpaceRX:SpaceLX

/**
 * 聊天消息cell
 */
@interface ZCChatBaseCell : UITableViewCell

/**
 *  显示时间
 */
@property (nonatomic,strong) UILabel                  *lblTime;


/**
 *  头像
 */
@property (nonatomic,strong) SobotImageView            *ivHeader; // 2.8.0 去掉


/**
 *
 *   留言转离线消息图标  2.8.0 改成文字
 *
 **/
@property (nonatomic,strong) UILabel * leaveIcon;

/**
 *  名称
 */
@property (nonatomic,strong) UILabel                  *lblNickName; // 2.8.0 去掉

/**
 *  气泡
 */
@property (nonatomic,strong) UIImageView              *ivBgView;

/**
 *  发送动画
 */
@property (nonatomic,strong) UIActivityIndicatorView  *activityView;

/**
 *  重新发送
 */
@property (nonatomic,strong) UIButton                 *btnReSend;

/**
 *  转人工
 */
@property (nonatomic,strong) UIButton                 *btnTurnUser;

/**
 *
 *  转人工 顶踩 按钮的背景View
 *
 **/
@property (nonatomic,strong) UIView                  *bottomBgView;

/**
 *  顶
 */
@property (nonatomic,strong) UIButton                 *btnTheTop;

/**
 *  踩
 */
@property (nonatomic,strong) UIButton                 *btnStepOn;


@property (nonatomic,strong) UILabel                  *lblRobotCommentResult;

/**
 *  映射view,做背景使用
 */
@property (nonatomic,strong) UIImageView              *ivLayerView;

/**
 *  当前展示的消息体
 */
@property (nonatomic,strong) ZCLibMessage             *tempModel;

/**
 *  是否是右边
 */
@property (nonatomic,assign) BOOL                     isRight;

/**
 *  最大宽度
 */
@property (nonatomic,assign) CGFloat                  maxWidth;

/**
 *  页面的宽度 ，气泡宽度
 */
@property (nonatomic,assign) CGFloat                  viewWidth;

/**
 *  外边距宽度
 */
@property (nonatomic,assign) CGFloat                  marginWidth;

/**
 *  内边距宽度
 */
@property (nonatomic,assign) CGFloat                  paddingWidth;

/**
 *  ZCChatCellDelegate的代理
 */
@property (nonatomic,weak) id<ZCChatCellDelegate>   delegate;

/**
 *  其它点击问题
 */
@property (nonatomic,strong) NSString     *callURL;



+(ZCMLEmojiLabel *) createRichLabel;

+(BOOL) isRightChat:(ZCLibMessage *) model;

/**
 *  设置数据到cell中
 *  头像、时间
 *
 *  @param model 消息体
 *  @param showTime 显示时间
 *
 *  @return 当前消息的高度
 */
-(CGFloat) InitDataToView:(ZCLibMessage *) model time:(NSString *) showTime;


/**
 *  根据显示气泡位置，设置发送状态
 *
 *  @param backgroundF  背景框的frame
 *  @return CGFloat 设置发送状态图标的位置
 */
-(CGFloat)setSendStatus:(CGRect )backgroundF;




/**
 *  是否显示 转人工 顶踩 按钮 以及背景 2.8.0 msg 是一行特殊判断
 *
 *
 **/
-(BOOL)isAddBottomBgView:(CGRect )backgroundF msgIsOneLine:(BOOL)isOneLine;


// 重置cell所有数据
-(void)resetCellView;



+(CGFloat)getCellHeight:(ZCLibMessage *)model time:(NSString *)showTime viewWith:(CGFloat )width;




/**
 *
 *  是否显示顶、踩、转人工
 *
 **/
+(CGFloat )getStatusHeight:(ZCLibMessage *) messageModel;



/// 设置字符串到UILabel中
/// @param attr 要设置的字符串
/// @param label ZCMLEmojiLabel
/// @param curModel 获取方向，根据方向设置颜色
/// @param isGuide 引导语
+(void)setDisplayAttributedString:(NSMutableAttributedString *) attr label:(UILabel *) label model:(ZCLibMessage *) curModel guide:(BOOL) isGuide;

@end
