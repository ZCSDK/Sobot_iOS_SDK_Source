//
//  SobotChatBaseCell.h
//  SobotOnline
//
//  Created by zhangxy on 2020/8/28.
//  Copyright © 2020 sobot. All rights reserved.
//


#import "ZCChatBaseCell.h"
#import "ZCMLEmojiLabel.h"

/**
 *  富媒体cell
 *  图片放大 电话链接 cell大小根据内容自适应
 */
@interface ZCChatAllRichCell : ZCChatBaseCell

+(CGSize )addRichView:(ZCLibMessage *) model width:(CGFloat ) maxWidth with:(UIView *) superView msgLabel:(ZCMLEmojiLabel *) richLabel;

@end
