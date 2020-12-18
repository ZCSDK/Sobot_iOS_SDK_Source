//
//  ZCUIChatListCell.h
//  SobotKit
//
//  Created by zhangxy on 2017/9/5.
//  Copyright © 2017年 zhichi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZCPlatformInfo.h"
#import "ZCUIImageView.h"

@interface ZCUIChatListCell : UITableViewCell

/**
 *  显示时间
 */
@property (nonatomic,strong) UILabel                  *lblTime;

/**
 *  头像
 */
@property (nonatomic,strong) ZCUIImageView            *ivHeader;

/**
 *  名称
 */
@property (nonatomic,strong) UILabel                  *lblNickName;
@property (nonatomic,strong) UILabel                  *lblLastMsg;
@property (nonatomic,strong) UILabel                  *lblUnRead;

-(void)dataToView:(ZCPlatformInfo *) info;


@end
