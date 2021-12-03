//
//  ZCChatBaseCell.m
//  SobotApp
//
//  Created by 张新耀 on 15/9/15.
//  Copyright (c) 2015年 com.sobot.chat. All rights reserved.
//

#import "ZCChatBaseCell.h"
#import "ZCLibCommon.h"
#import "ZCUITools.h"
#import "ZCLibGlobalDefine.h"
//#import "ZCUIXHImageViewer.h"
#import "SobotImageView.h"
#import "ZCIMChat.h"
#import "ZCStoreConfiguration.h"
#import "ZCLibClient.h"
#import "ZCPlatformTools.h"
#import "ZCUIColorsDefine.h"
#import "ZCToolsCore.h"

@interface ZCChatBaseCell(){
    
    
    UIView * topline;
    
    UIView  * leftLine;
    
    UIView  * midLine;
    
    UIView  * rightLine;
}

@end

@implementation ZCChatBaseCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        
        self.marginWidth = 12;
        self.paddingWidth = 15;
        
        _lblTime=[[UILabel alloc] init];
        [_lblTime setTextAlignment:NSTextAlignmentCenter];
        [_lblTime setFont:[ZCUITools zcgetListKitTimeFont]];
        [_lblTime setTextColor:[ZCUITools zcgetTimeTextColor]];
        [_lblTime setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_lblTime];
        _lblTime.hidden=YES;
        
        _ivBgView = [[UIImageView alloc] init];
        [_ivBgView setContentMode:UIViewContentModeScaleAspectFit];
        [_ivBgView.layer setMasksToBounds:YES];
        [_ivBgView setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_ivBgView];
        
        
        _btnReSend =[UIButton buttonWithType:UIButtonTypeCustom];
        [_btnReSend setBackgroundColor:[UIColor clearColor]];
        _btnReSend.layer.cornerRadius=3;
        _btnReSend.layer.masksToBounds=YES;
        [self.contentView addSubview:_btnReSend];
        _btnReSend.hidden=YES;
        
        // 2.7.4新增 2.8.0 改成文字
        _leaveIcon = [[UILabel alloc]init];
//        _leaveIcon = ZCSTLocalString(@"留言消息");
        _leaveIcon.text = ZCSTLocalString(@"留言消息");
        _leaveIcon.textColor = [ZCUITools zcgetRightChatColor];
        _leaveIcon.font = ZCUIFont12;
        [_leaveIcon setTextAlignment:NSTextAlignmentRight];
        [self.contentView addSubview:_leaveIcon];
        _leaveIcon.hidden = YES;
        
        // 2.6.5新增
        //        _bottomBgView = [[UIView alloc]init];
        //        [_bottomBgView.layer setMasksToBounds:YES];
        //        [_bottomBgView setBackgroundColor:[UIColor clearColor]];
        //        [self.contentView addSubview:_bottomBgView];
        
        _btnTurnUser =[UIButton buttonWithType:UIButtonTypeCustom];
        [_btnTurnUser setBackgroundColor:UIColorFromThemeColor(ZCBgSystemWhiteLightGrayColor)];
        [_btnTurnUser setTitle:ZCSTLocalString(@"转人工") forState:UIControlStateNormal];
        _btnTurnUser.tag = ZCChatCellClickTypeConnectUser;
        if([ZCUITools getZCThemeStyle] != ZCThemeStyle_Dark){
            _btnTurnUser.layer.borderColor = UIColorFromThemeColor(ZCTextNoticeLinkColor).CGColor;
        }
        _btnTurnUser.layer.cornerRadius = 15.0f;
        _btnTurnUser.layer.borderWidth = 0.75f;
        _btnTurnUser.layer.masksToBounds = YES;
        
        [_btnTurnUser setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_turnserver_nol"] forState:UIControlStateNormal];
        [_btnTurnUser setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_turnserver_nol"] forState:UIControlStateHighlighted];
        _btnTurnUser.imageEdgeInsets = UIEdgeInsetsMake(0,-10.0, 0, 0);
        _btnTurnUser.titleEdgeInsets = UIEdgeInsetsMake(0, 15.0, 0, 0);
        
        
        [_btnTurnUser.titleLabel setFont:ZCUIFont14];
        [_btnTurnUser setTitleColor:UIColorFromThemeColor(ZCTextMainColor) forState:UIControlStateNormal];
        [_btnTurnUser addTarget:self action:@selector(connectWithStepOnWithTheTop:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_btnTurnUser];
        _btnTurnUser.hidden=YES;
        
        
        _btnStepOn =[UIButton buttonWithType:UIButtonTypeCustom];
        _btnStepOn.backgroundColor =UIColorFromThemeColor(ZCBgSystemWhiteLightGrayColor);
        _btnStepOn.layer.cornerRadius = 16.0f;
        _btnStepOn.layer.shadowOpacity= 1;
        _btnStepOn.layer.shadowColor = UIColorFromThemeColorAlpha(ZCTextMainColor, 0.15).CGColor;
        _btnStepOn.layer.shadowOffset = CGSizeZero;//投影偏移
        _btnStepOn.layer.shadowRadius = 2;
        
        //        [_btnStepOn setTitle:@"无用" forState:UIControlStateNormal]; zcicon_useless_nol zcicon_useless_sel
        _btnStepOn.tag = ZCChatCellClickTypeStepOn;
//        [_btnStepOn.titleLabel setFont:[ZCUITools zcgetListKitDetailFont]];
        [_btnStepOn setContentMode:UIViewContentModeRight];
        [_btnStepOn setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_useless_nol"] forState:UIControlStateNormal];
        [_btnTheTop setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_useless_sel"] forState:UIControlStateHighlighted];
        [_btnStepOn addTarget:self action:@selector(connectWithStepOnWithTheTop:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_btnStepOn];
        _btnStepOn.hidden=YES;
        
        _btnTheTop =[UIButton buttonWithType:UIButtonTypeCustom];
//        [_btnTheTop setBackgroundColor:[UIColor clearColor]];
        [_btnTheTop setContentMode:UIViewContentModeRight];
        _btnTheTop.backgroundColor = UIColorFromThemeColor(ZCBgSystemWhiteLightGrayColor);
//        [_btnTheTop.titleLabel setFont:[ZCUITools zcgetListKitDetailFont]];
        _btnTheTop.layer.cornerRadius = 16.0f;
        _btnTheTop.layer.shadowOpacity= 1;
        _btnTheTop.layer.shadowColor = UIColorFromThemeColorAlpha(ZCTextMainColor, 0.15).CGColor;
        _btnTheTop.layer.shadowOffset = CGSizeZero;//投影偏移
        _btnTheTop.layer.shadowRadius = 2;
        

        [_btnTheTop setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_useless_sel"] forState:UIControlStateNormal];
        [_btnTheTop setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_useful_sel"] forState:UIControlStateHighlighted];
        _btnTheTop.tag = ZCChatCellClickTypeTheTop;
        [_btnTheTop addTarget:self action:@selector(connectWithStepOnWithTheTop:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_btnTheTop];
        _btnTheTop.hidden=YES;
        
        // 2.6.5改版 不在显示 当前控件 使用tost 显示
//        _lblRobotCommentResult =[[UILabel alloc] init];
//        [_lblRobotCommentResult setBackgroundColor:[UIColor clearColor]];
//        [_lblRobotCommentResult setTextAlignment:NSTextAlignmentLeft];
//        [_lblRobotCommentResult setFont:[ZCUITools zcgetListKitDetailFont]];
//        [_lblRobotCommentResult setTextColor:[ZCUITools zcgetTimeTextColor]];
//        [_lblRobotCommentResult setBackgroundColor:[UIColor clearColor]];
//        //        [self.contentView addSubview:_lblRobotCommentResult];
//        _lblRobotCommentResult.hidden=YES;
        
        
        
        _activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//        _activityView.hidden=YES;
//        _activityView.hidesWhenStopped = YES;
        [self.contentView addSubview:_activityView];
        
        
        _ivLayerView = [[UIImageView alloc] init];
        
        self.userInteractionEnabled=YES;
    }
    return self;
}
-(ZCLibConfig *)getCurConfig{
    return [[ZCPlatformTools sharedInstance] getPlatformInfo].config;
}


+(ZCMLEmojiLabel *) createRichLabel{
    ZCMLEmojiLabel *tempRichLabel = [[ZCMLEmojiLabel alloc] initWithFrame:CGRectZero];
    tempRichLabel.numberOfLines = 0;
    tempRichLabel.font = [ZCUITools zcgetKitChatFont];
    tempRichLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    tempRichLabel.textColor = [UIColor whiteColor];
    tempRichLabel.backgroundColor = [UIColor clearColor];
    tempRichLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    //        _lblTextMsg.textInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    
    tempRichLabel.isNeedAtAndPoundSign = NO;
    tempRichLabel.disableEmoji = NO;
    
    tempRichLabel.lineSpacing = [ZCUITools zcgetChatLineSpacing];
    
    tempRichLabel.verticalAlignment = ZCTTTAttributedLabelVerticalAlignmentCenter;
    return tempRichLabel;
}



-(CGFloat)InitDataToView:(ZCLibMessage *)model time:(NSString *)showTime{
    
    float gapWidth = 70; //
    
    self.maxWidth = self.viewWidth - gapWidth;
    // 有顶 踩
//    if (model.senderType == 1 && (model.commentType == 1 || model.commentType == 2||model.commentType == 3|| model.commentType == 4)) {
//        self.maxWidth = self.viewWidth - gapWidth - btnTheTopSize.width - 25;
//    }
    
    CGFloat cellHeight=0;
    
    [self resetCellView];
    
    _tempModel = model;
    if(![@"" isEqual:zcLibConvertToString(showTime)]){
        [_lblTime setText:showTime];
        [_lblTime setFrame:CGRectMake(0, 0, self.viewWidth, 30)];
        _lblTime.hidden=NO;
        cellHeight = 30 ;
    }
    
    cellHeight = cellHeight + 10;
    
    UIImage *bgImage = [UIImage new];
    
    // 0,自己，1机器人，2客服
    if(model.senderType==0){
        _isRight = YES;
        // 右边气泡背景图片
        bgImage = [ZCUITools zcuiGetBundleImage:@"zcicon_pop_green_normal"];
        bgImage=[bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(21, 21, 21, 21)];
        
        [_ivBgView setBackgroundColor:[ZCUITools zcgetRightChatColor]];
        
        self.ivBgView.image = nil;
    }else{
        _isRight = NO;
        bgImage = [ZCUITools zcuiGetBundleImage:@"zcicon_pop_green_left_normal"];
        bgImage=[bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(21, 21, 21, 21)];
        
        [_ivBgView setBackgroundColor:[ZCUITools zcgetLeftChatColor]];
        self.ivBgView.image = nil;
    }
    //设置尖角
    [_ivLayerView setImage:bgImage];
    return cellHeight;
}

+(BOOL) isRightChat:(ZCLibMessage *) model{
    // 0,自己，1机器人，2客服
    if(model.senderType==0){
        return YES;
    }else{
        return NO;
    }
}

-(CGFloat)setSendStatus:(CGRect )backgroundF{
    _leaveIcon.hidden = YES;
    // 自己、设置发送状态
    if(_tempModel.senderType==0){
        if(_tempModel.sendStatus==0){
            self.btnReSend.hidden=YES;
            if(_tempModel.richModel.msgType == ZCMessageTypeFile){
                // 发送文件时，不显示发送的动画，由发送进度代替
//                [self.btnReSend setHidden:YES];
                [_activityView removeFromSuperview];
                [_activityView stopAnimating];
                return 0;
            }
        }else if(_tempModel.sendStatus==1){
            if(_tempModel.richModel.msgType == 1){
                // 发送图片时，不显示发送的动画，由发送进度代替
                [self.btnReSend setHidden:YES];
                return 0;
            }
            
            if(_tempModel.richModel.msgType == ZCMessageTypeFile){
                // 发送文件时，不显示发送的动画，由发送进度代替
                //                [self.btnReSend setHidden:YES];
                [_activityView removeFromSuperview];
                [_activityView stopAnimating];
                return 0;
            }
            [self.btnReSend setHidden:NO];
            [self.btnReSend setBackgroundColor:[UIColor clearColor]];
            [self.btnReSend setImage:nil forState:UIControlStateNormal];
            [self.btnReSend setFrame:CGRectMake(backgroundF.origin.x-34, backgroundF.origin.y + backgroundF.size.height/2 - 12, 24, 24)];
            
            self.activityView.hidden=YES;
            _activityView.center = self.btnReSend.center;
            [_activityView startAnimating];
        }else if(_tempModel.sendStatus==2){
            [self.btnReSend setHidden:NO];
            [self.btnReSend setBackgroundColor:[UIColor clearColor]];
            [self.btnReSend setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_send_fail"] forState:UIControlStateNormal];
            [self.btnReSend setFrame:CGRectMake(backgroundF.origin.x-34,backgroundF.origin.y + backgroundF.size.height/2 - 10, 20, 20)];
            [self.btnReSend addTarget:self action:@selector(clickReSend:) forControlEvents:UIControlEventTouchUpInside];
            
            _activityView.hidden=YES;
            [_activityView stopAnimating];
        }
        
        // 是否是用户发送的 留言转离线消息
        if (_tempModel.leaveMsgFlag == 1) {
            _leaveIcon.hidden = NO;
            
            [self.leaveIcon setFrame:CGRectMake(backgroundF.origin.x- 95, backgroundF.origin.y + backgroundF.size.height/2 - 12, 90, 24)];
            
        }
    }else{
        // 设置未读状态
        if(_tempModel.isRead){
            [self.btnReSend setHidden:NO];
            [self.btnReSend setImage:nil forState:UIControlStateNormal];
            
            [self.btnReSend setFrame:CGRectMake(backgroundF.origin.x+backgroundF.size.width+10, backgroundF.origin.y+10, 6, 6)];
        }
    }
    
    CGFloat showheight = 0;
    
    // 机器人回复，判断是否显示“顶、踩、转人工”
    if(_tempModel.senderType == 1){
        if([self getCurConfig].isArtificial){
            self.tempModel.showTurnUser = NO;
        }
        showheight = [ZCChatBaseCell getStatusHeight:self.tempModel];
    }
    return showheight;
}

-(BOOL)isAddBottomBgView:(CGRect )backgroundF1 msgIsOneLine:(BOOL)isOneLine{
    self.btnTurnUser.hidden = YES;
    self.btnStepOn.hidden = YES;
    self.btnTheTop.hidden = YES;
    self.bottomBgView.hidden = YES;
    if (self.isRight) {
        //       [self.bottomBgView setBackgroundColor:[ZCUITools zcgetRightChatColor]];
    }else{
        //        [self.bottomBgView setBackgroundColor:[ZCUITools zcgetLeftChatColor]];
    }
    
    
    NSMutableArray * arr = [NSMutableArray arrayWithCapacity:0];
    
    CGFloat showheight = 0;
    
    // 机器人回复，判断是否显示“顶、踩、转人工”
    if(_tempModel.senderType == 1){
        if([self getCurConfig].isArtificial){
            self.tempModel.showTurnUser = NO;
        }
        
        int temptype = [self getCurConfig].type ;
        
        if ([ZCLibClient getZCLibClient].libInitInfo.service_mode >0 ) {
            temptype = [ZCLibClient getZCLibClient].libInitInfo.service_mode;
        }
        
        NSString * easyui = @"0";
        if (self.tempModel.commentType == 4) {
            easyui = @"1";
        }
        
        
        if(_tempModel.showTurnUser && ![self getCurConfig].isArtificial &&  temptype != 1){
            
            
            NSDictionary * dict1 = @{@"title":ZCSTLocalString(@"转人工"),
                                     @"selImg":@"zcicon_turnserver_nol",
                                     @"nolImg":@"zcicon_turnserver_nol",
                                     @"status":@"0",
                                     @"isEnabled":@"1",
                                     @"easyui":easyui
                                     };
            [arr addObject:dict1];
            self.btnTurnUser.hidden = NO;
            //            self.bottomBgView.hidden = NO;
            showheight = 40.0f;
        }
        
        if(self.tempModel.commentType > 0){
            self.btnTheTop.hidden = NO;
            self.btnStepOn.hidden = NO;
            self.bottomBgView.hidden = NO;
            
            self.btnTheTop.enabled = YES;
            self.btnStepOn.enabled = YES;
            
            if(self.tempModel.commentType == 1){
                
                NSDictionary * dict2 = @{@"title":ZCSTLocalString(@"YES"),
                                         @"selImg":@"zcicon_useful_sel",
                                         @"nolImg":@"zcicon_useful_nol",
                                         @"status":@"0",
                                         @"isEnabled":@"1",
                                         @"easyui":easyui
                                         };
                
                NSDictionary * dict3 = @{@"title":ZCSTLocalString(@"NoUse"),
                                         @"selImg":@"zcicon_useless_sel",
                                         @"nolImg":@"zcicon_useless_nol",
                                         @"status":@"0",
                                         @"isEnabled":@"1",
                                         @"easyui":easyui
                                         };
                
                [arr addObject:dict2];
                [arr addObject:dict3];
            }else{
                // 已赞
                if(self.tempModel.commentType == 2){
                    NSDictionary * dict2 = @{@"title":ZCSTLocalString(@"YES"),
                                             @"selImg":@"zcicon_useful_sel",
                                             @"nolImg":@"zcicon_useful_nol",
                                             @"status":@"1",
                                             @"isEnabled":@"0",
                                             @"easyui":easyui
                                             };
                    
                    NSDictionary * dict3 = @{@"title":ZCSTLocalString(@"NoUse"),
                                             @"selImg":@"zcicon_useless_sel",
                                             @"nolImg":@"zcicon_useless_nol",
                                             @"status":@"0",
                                             @"isEnabled":@"0",
                                             @"easyui":@"1"
                                             };
                    
                    [arr addObject:dict2];
                    [arr addObject:dict3];
                    self.btnTheTop.enabled = NO;
                    self.btnStepOn.enabled = NO;
                }else if(self.tempModel.commentType == 3){// 已踩
                    NSDictionary * dict2 = @{@"title":ZCSTLocalString(@"YES"),
                                             @"selImg":@"zcicon_useful_sel",
                                             @"nolImg":@"zcicon_useful_nol",
                                             @"status":@"0",
                                             @"isEnabled":@"0",
                                             @"easyui":@"1"
                                             };
                    
                    NSDictionary * dict3 = @{@"title":ZCSTLocalString(@"NoUse"),
                                             @"selImg":@"zcicon_useless_sel",
                                             @"nolImg":@"zcicon_useless_nol",
                                             @"status":@"1",
                                             @"isEnabled":@"0",
                                             @"easyui":@"0"
                                             };
                    self.btnTheTop.enabled = NO;
                    self.btnStepOn.enabled = NO;
                    [arr addObject:dict2];
                    [arr addObject:dict3];
                }else if (self.tempModel.commentType == 4){
                    NSDictionary * dict2 = @{@"title":ZCSTLocalString(@"YES"),
                                             @"selImg":@"zcicon_useful_sel",
                                             @"nolImg":@"zcicon_useful_nol",
                                             @"status":@"0",
                                             @"isEnabled":@"0",
                                             @"easyui":easyui
                                             };
                    
                    NSDictionary * dict3 = @{@"title":ZCSTLocalString(@"NoUse"),
                                             @"selImg":@"zcicon_useless_sel",
                                             @"nolImg":@"zcicon_useless_nol",
                                             @"status":@"0",
                                             @"isEnabled":@"0",
                                             @"easyui":easyui
                                             };
                    self.btnTheTop.enabled = NO;
                    self.btnStepOn.enabled = NO;
                    [arr addObject:dict2];
                    [arr addObject:dict3];
                }
            }
            
            showheight = 40.0f;
        }
        
        // 要显示顶踩 和转人工
        if (showheight >0) {
//            CGFloat W = CGRectGetWidth(self.bottomBgView.frame);
            
            // 布局 bottomBGView
            if (arr.count == 1) {
                // 只有 转人工
                self.btnTurnUser.frame = CGRectMake(backgroundF1.origin.x, CGRectGetMaxY(backgroundF1) + 10, 100 , 30);
                NSDictionary * dict = arr[0];
                [self.btnTurnUser setTitleColor:[ZCUITools zcgetTopBtnNolColor] forState:UIControlStateNormal];
                [self.btnTurnUser setTitle:ZCSTLocalString(@"转人工") forState:UIControlStateNormal];
                
                if ([dict[@"easyui"] intValue] ==1) {
                    [self.btnTurnUser setTitleColor:[ZCUITools zcgetTopBtnGreyColor] forState:UIControlStateNormal];
                }
                
            }else if (arr.count == 2){
                // 只有顶踩
                self.btnTheTop.frame = CGRectMake(CGRectGetMaxX(backgroundF1)+10, CGRectGetMaxY(backgroundF1) - 32*2 - 8, 32, 32);
                if (isOneLine) {
                    self.btnTheTop.frame = CGRectMake(CGRectGetMaxX(backgroundF1)+10, CGRectGetMaxY(backgroundF1) - 32*2 - 3, 32, 32);
                }
                
                NSDictionary * dict = arr[0];
                
                [self.btnTheTop setImage:[ZCUITools zcuiGetBundleImage:dict[@"nolImg"]] forState:UIControlStateNormal];
                [self.btnTheTop setImage:[ZCUITools zcuiGetBundleImage:dict[@"selImg"]] forState:UIControlStateHighlighted];
                if ([dict[@"easyui"] intValue] ==1) {
                }
                
                // 选中
                if ([dict[@"status"] intValue] == 1) {
                    [self.btnTheTop setImage:[ZCUITools zcuiGetBundleImage:dict[@"selImg"]] forState:UIControlStateNormal];
                    [self.btnTheTop setImage:[ZCUITools zcuiGetBundleImage:dict[@"selImg"]] forState:UIControlStateHighlighted];
                    [self.btnTheTop setImage:[ZCUITools zcuiGetBundleImage:dict[@"selImg"]] forState:UIControlStateDisabled];

                    if (isOneLine) {
                        self.btnTheTop.frame = CGRectMake(CGRectGetMaxX(backgroundF1)+10 , CGRectGetMaxY(backgroundF1) - 32   , 32, 32);
                    }else{
                        self.btnTheTop.frame = CGRectMake(CGRectGetMaxX(backgroundF1)+10 , CGRectGetMaxY(backgroundF1) - 32  , 32, 32);
                    }
                    
                    self.btnStepOn.hidden = YES;
                }
                
                self.btnStepOn.frame = CGRectMake(CGRectGetMaxX(backgroundF1)+10 , CGRectGetMaxY(self.btnTheTop.frame) + 8, 32, 32);
                NSDictionary * dict1 = arr[1];
                
                [self.btnStepOn setImage:[ZCUITools zcuiGetBundleImage:dict1[@"nolImg"]] forState:UIControlStateNormal];
                [self.btnStepOn setImage:[ZCUITools zcuiGetBundleImage:dict1[@"selImg"]] forState:UIControlStateHighlighted];
                
                if ([dict1[@"easyui"] intValue] ==1) {
                    //                    [self.btnStepOn setTitleColor:[ZCUITools zcgetTopBtnGreyColor] forState:UIControlStateNormal];
                }
                
                // 选中
                if ([dict1[@"status"] intValue] == 1) {
                    [self.btnStepOn setImage:[ZCUITools zcuiGetBundleImage:dict1[@"selImg"]] forState:UIControlStateNormal];
                    [self.btnStepOn setImage:[ZCUITools zcuiGetBundleImage:dict1[@"selImg"]] forState:UIControlStateHighlighted];
                    [self.btnStepOn setImage:[ZCUITools zcuiGetBundleImage:dict1[@"selImg"]] forState:UIControlStateDisabled];

                    if (isOneLine) {
                        self.btnStepOn.frame = CGRectMake(CGRectGetMaxX(backgroundF1)+10 , CGRectGetMaxY(backgroundF1) - 32   , 32, 32);
                    }else{
                        self.btnStepOn.frame = CGRectMake(CGRectGetMaxX(backgroundF1)+10 , CGRectGetMaxY(backgroundF1) - 32   , 32, 32);

                    }
                    
                    self.btnTheTop.hidden = YES;
                }
                
            }else if (arr.count == 3){
                // 三者都有
                self.btnTurnUser.frame = CGRectMake(backgroundF1.origin.x, CGRectGetMaxY(backgroundF1) + 10, 100 , 30);
                NSDictionary * dict = arr[0];
                [self.btnTurnUser setTitleColor:[ZCUITools zcgetTopBtnNolColor] forState:UIControlStateNormal];
                
                if ([dict[@"easyui"] intValue] ==1) {
                    [self.btnTurnUser setTitleColor:[ZCUITools zcgetTopBtnGreyColor] forState:UIControlStateNormal];
                }
                
                self.btnTheTop.frame = CGRectMake(CGRectGetMaxX(backgroundF1)+10, CGRectGetMaxY(backgroundF1) - 32*2 - 8, 32, 32);
                if (isOneLine) {
                    self.btnTheTop.frame = CGRectMake(CGRectGetMaxX(backgroundF1)+10, CGRectGetMaxY(backgroundF1) - 32*2 - 8 , 32, 32);
                }
                NSDictionary * dict1 = arr[1];
                
                [self.btnTheTop setImage:[ZCUITools zcuiGetBundleImage:dict1[@"nolImg"]] forState:UIControlStateNormal];
                [self.btnTheTop setImage:[ZCUITools zcuiGetBundleImage:dict1[@"selImg"]] forState:UIControlStateHighlighted];
                
                if ([dict1[@"easyui"] intValue] ==1) {
                    [self.btnTheTop setTitleColor:[ZCUITools zcgetTopBtnGreyColor] forState:UIControlStateNormal];
                }
                
                // 选中
                if ([dict1[@"status"] intValue] == 1) {
                    [self.btnTheTop setTitleColor:[ZCUITools zcgetTopBtnSelColor] forState:UIControlStateNormal];
                    [self.btnTheTop setImage:[ZCUITools zcuiGetBundleImage:dict1[@"selImg"]] forState:UIControlStateNormal];
                    [self.btnTheTop setImage:[ZCUITools zcuiGetBundleImage:dict1[@"selImg"]] forState:UIControlStateHighlighted];
                                    [self.btnTheTop setImage:[ZCUITools zcuiGetBundleImage:dict1[@"selImg"]] forState:UIControlStateDisabled];
                    if (isOneLine) {
                        self.btnTheTop.frame = CGRectMake(CGRectGetMaxX(backgroundF1)+10 , CGRectGetMaxY(backgroundF1) - 32   , 32, 32);
                    }else{
                        self.btnTheTop.frame = CGRectMake(CGRectGetMaxX(backgroundF1)+10 , CGRectGetMaxY(backgroundF1) - 32   , 32, 32);

                    }
                    
                    self.btnStepOn.hidden = YES;
                }
                
                self.btnStepOn.frame = CGRectMake(CGRectGetMaxX(backgroundF1)+10 , CGRectGetMaxY(self.btnTheTop.frame) + 8, 32, 32);
                NSDictionary * dict2 = arr[2];
                
                [self.btnStepOn setImage:[ZCUITools zcuiGetBundleImage:dict2[@"nolImg"]] forState:UIControlStateNormal];
                [self.btnStepOn setImage:[ZCUITools zcuiGetBundleImage:dict2[@"selImg"]] forState:UIControlStateHighlighted];
                
                if ([dict2[@"easyui"] intValue] ==1) {
                    [self.btnStepOn setTitleColor:[ZCUITools zcgetTopBtnGreyColor] forState:UIControlStateNormal];
                }
                
                // 选中
                if ([dict2[@"status"] intValue] == 1) {
                    [self.btnStepOn setTitleColor:[ZCUITools zcgetTopBtnSelColor] forState:UIControlStateNormal];
                    [self.btnStepOn setImage:[ZCUITools zcuiGetBundleImage:dict2[@"selImg"]] forState:UIControlStateNormal];
                    [self.btnStepOn setImage:[ZCUITools zcuiGetBundleImage:dict2[@"selImg"]] forState:UIControlStateHighlighted];
                    [self.btnStepOn setImage:[ZCUITools zcuiGetBundleImage:dict2[@"selImg"]] forState:UIControlStateDisabled];

                    
                    if (isOneLine) {
                        self.btnStepOn.frame = CGRectMake(CGRectGetMaxX(backgroundF1)+10 , CGRectGetMaxY(backgroundF1) - 32   , 32, 32);
                    }else{
                        self.btnStepOn.frame = CGRectMake(CGRectGetMaxX(backgroundF1)+10 , CGRectGetMaxY(backgroundF1) - 32   , 32, 32);

                    }
                    
                    self.btnTheTop.hidden = YES;
                }
                
            }
            
        }
    }
    
    if(arr.count == 1 ||arr.count == 3){
        return YES;
    }else{
        return NO;
    }
    
}

-(void)headerClick:(UITapGestureRecognizer *)gesture{
    if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]){
        [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeHeader obj:nil];
    }
}

-(void)connectWithStepOnWithTheTop:(UIButton *) btn{
    if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]){
        [self.delegate cellItemClick:self.tempModel type:btn.tag obj:nil];
    }
    
}



// 重新发送
-(IBAction)clickReSend:(UIButton *)sender{

    
    [[ZCToolsCore getToolsCore] showAlert:nil message:ZCSTLocalString(@"重新发送") cancelTitle:ZCSTLocalString(@"取消") viewController:[self getControllerFromView:self] confirm:^(NSInteger buttonTag) {
        if(buttonTag>=0){
            if(_delegate && [_delegate respondsToSelector:@selector(cellItemClick:type:obj:)]){
                [_delegate cellItemClick:_tempModel type:ZCChatCellClickTypeReSend obj:nil];
            }
            
        }
        
        
    } buttonTitles:ZCSTLocalString(@"发送"), nil];
    
}

- (UIViewController *)getControllerFromView:(UIView *)view {
    // 遍历响应者链。返回第一个找到视图控制器
    UIResponder *responder = view;
    while ((responder = [responder nextResponder])){
        if ([responder isKindOfClass: [UIViewController class]]){
            return (UIViewController *)responder;
        }
    }
    // 如果没有找到则返回nil
    return nil;
}



-(void)resetCellView{
    _lblTime.hidden=YES;
    [_lblTime setText:@""];
    
    _activityView.hidden=YES;
    
    _btnReSend.hidden=YES;
    
    [_activityView stopAnimating];
    [_activityView setHidden:YES];
    
//    if(_ivBgView){
        _ivBgView.hidden=NO;
        [_ivBgView.layer.mask removeFromSuperlayer];
//    }
    
    if(_ivHeader){
        _ivHeader.image = nil;
    }
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


+(CGFloat)getCellHeight:(ZCLibMessage *)model time:(NSString *)showTime viewWith:(CGFloat )viewWidth{
    CGFloat cellheight = 0;
    if(![@"" isEqual:zcLibConvertToString(showTime)]){
        cellheight = 30;
    }
    cellheight=cellheight+10;
    
    // 0,自己，1机器人，2客服
    //    if(model.senderType!=0){
    //        cellheight = cellheight + 5;
    //    }
    //
    //    if (model.senderType ==0 ) {
    //        if (![@"" isEqual:zcLibConvertToString([ZCLibClient getZCLibClient].libInitInfo.user_nick)]) {
    //            // 设置内容的Y坐标
    //            cellheight=cellheight+5;
    //        }
    //    }
    
    cellheight = cellheight + [self getStatusHeight:model];
    
    return cellheight;
    
}


+(CGFloat )getStatusHeight:(ZCLibMessage *) messageModel{
    CGFloat showheight = 0;
    // 机器人回复，判断是否显示“顶、踩、转人工”
    if(messageModel.senderType == 1){
        int temptype = [[ZCPlatformTools sharedInstance] getPlatformInfo].config.type ;
        
        if ([ZCLibClient getZCLibClient].libInitInfo.service_mode > 0 ) {
            temptype = [ZCLibClient getZCLibClient].libInitInfo.service_mode;
        }
        
        // 显示转人工按钮，并且当前不是仅人工模式和人工接待状态
        if(messageModel.showTurnUser && ![[ZCPlatformTools sharedInstance] getPlatformInfo].config.isArtificial &&  temptype != 1){
            showheight = 20.0f;
        }
        
        if(messageModel.commentType > 0){
//            showheight = 20.0f;
        }
    }
    return showheight;
}



+(void)setDisplayAttributedString:(NSMutableAttributedString *) attr label:(UILabel *) label model:(ZCLibMessage *)curModel guide:(BOOL)isGuide{
    UIColor *textColor = [ZCUITools zcgetLeftChatTextColor];
    UIColor *linkColor = [ZCUITools zcgetChatLeftLinkColor];
    if([self isRightChat:curModel]){
        textColor = [ZCUITools zcgetRightChatTextColor];
        linkColor = [ZCUITools zcgetChatRightlinkColor];
    }
    NSMutableAttributedString* attributedString = [attr mutableCopy];
     
    [attributedString beginEditing];
    [attributedString enumerateAttribute:NSFontAttributeName inRange:NSMakeRange(0,attributedString.length) options:0 usingBlock:^(id value,NSRange range,BOOL *stop) {
        UIFont *font = value;
        // 替换固定默认文字大小
        if(font.pointSize == 15){
//            NSLog(@"----替换了字体");
            [attributedString removeAttribute:NSFontAttributeName range:range];
            [attributedString addAttribute:NSFontAttributeName value:label.font range:range];
        }
    }];
    [attributedString enumerateAttribute:NSForegroundColorAttributeName inRange:NSMakeRange(0,attributedString.length) options:0 usingBlock:^(id value,NSRange range,BOOL *stop) {
        UIColor *color = value;
        NSString *hexColor = [ZCUITools getHexStringByColor:color];
//                                NSLog(@"***\n%@",hexColor);
        // 替换固定整体文字颜色
        if([@"ff0001" isEqual:hexColor]){
            [attributedString removeAttribute:NSForegroundColorAttributeName range:range];
            [attributedString addAttribute:NSForegroundColorAttributeName value:textColor range:range];
        }
        // 替换固定连接颜色
        if([@"ff0002" isEqual:hexColor]){
            [attributedString removeAttribute:NSForegroundColorAttributeName range:range];
            [attributedString addAttribute:NSForegroundColorAttributeName value:linkColor range:range];
        }
    }];
    
    // 文本段落排版格式
    NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle alloc] init];
    textStyle.lineBreakMode = NSLineBreakByWordWrapping; // 结尾部分的内容以……方式省略
    if (isGuide) {
        textStyle.lineSpacing = [ZCUITools zcgetChatGuideLineSpacing]; // 调整行间距
    }else{
        textStyle.lineSpacing = [ZCUITools zcgetChatLineSpacing]; // 调整行间距
    }
    NSMutableDictionary *textAttributes = [[NSMutableDictionary alloc] init];
    // NSParagraphStyleAttributeName 文本段落排版格式
    [textAttributes setValue:textStyle forKey:NSParagraphStyleAttributeName];
    // 设置段落样式
    [attributedString addAttributes:textAttributes range:NSMakeRange(0, attributedString.length)];
    [attributedString endEditing];
    
    label.text = [attributedString copy];
}

@end
