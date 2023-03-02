//
//  ZCFileCell.m
//  SobotKit
//
//  Created by zhangxy on 2018/11/13.
//  Copyright © 2018年 zhichi. All rights reserved.
//

#import "ZCFileCell.h"
#import "ZCProgressView.h"
#import "ZCLibGlobalDefine.h"
#import "ZCUIColorsDefine.h"
#import "ZCToolsCore.h"
#import "ZCVideoPlayer.h"
#import "ZCMLEmojiLabel.h"
#import "ZCHtmlCore.h"
#define FileHeight 60
#import "ZCPlatformTools.h"
@interface ZCFileCell()<ZCMLEmojiLabelDelegate>{
//    UIView *_bgView;
    ZCProgressView *_progressView;
    UILabel *_labFileName;
    UILabel *_labFileSize;
    UIButton * cancelBtn;// 取消发送；
    ZCLibMessage *_model;
    UIView *_tapView;
}
@property (nonatomic,strong) ZCMLEmojiLabel *suglabel;
@end

@implementation ZCFileCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        
//        _bgView = [[UIView alloc]init];
//        _bgView.layer.cornerRadius = 10;
//        _bgView.layer.borderWidth = 1;
//        _bgView.layer.borderColor = [ZCUITools zcgetRightChatColor].CGColor;
//        [self.contentView addSubview:_bgView];
        
        _progressView = [[ZCProgressView alloc] init];
        [_progressView.layer setMasksToBounds:YES];
        [_progressView setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_progressView];
        
        _labFileName=[[UILabel alloc] init];
        [_labFileName setTextAlignment:NSTextAlignmentLeft];
        [_labFileName setFont:ZCUIFontBold14];
        [_labFileName setTextColor:UIColorFromThemeColor(ZCTextMainColor)];
        [_labFileName setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_labFileName];
        
        _labFileSize=[[UILabel alloc] init];
        [_labFileSize setTextAlignment:NSTextAlignmentLeft];
        [_labFileSize setFont:ZCUIFont12];
        [_labFileSize setTextColor:UIColorFromThemeColor(ZCTextSubColor)];
        [_labFileSize setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_labFileSize];
        
        //设置点击事件
        UITapGestureRecognizer *tapGesturer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
//        _bgView.userInteractionEnabled=YES;
        
    
        _tapView = [[UIView alloc]init];
        _tapView.userInteractionEnabled=YES;
        [self.contentView addSubview:_tapView];

        [_tapView addGestureRecognizer:tapGesturer];
        
        cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelBtn setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_close_down"] forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(cancelSendMsg:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:cancelBtn];
        
    }
    return self;
}


-(CGFloat) InitDataToView:(ZCLibMessage *)model time:(NSString *)showTime{
    CGFloat height=[super InitDataToView:model time:showTime];
    _model = model;
    _suglabel.text = @"";
    _suglabel = nil;
    [_progressView setFaceImage:[ZCUITools getFileIcon:model.richModel.url fileType:model.richModel.fileType]];
    [_labFileSize setText:model.richModel.fileSize];
    [_labFileName setText:sobotTrimString(model.richModel.fileName)];
    if (model.isHistory) {
        model.progress = 1.0;
    }
    [_progressView setProgress:model.progress];
    self.ivBgView.hidden = NO;
    CGFloat msgX = 0;
    CGSize bgSize = CGSizeMake(self.maxWidth, 70 - 5);
    CGSize iconSize = CGSizeMake(34, 40);
    // 0,自己，1机器人，2客服
    if(self.isRight){
        int rx=self.viewWidth-bgSize.width-15;
        msgX = rx;
        self.ivBgView.frame = CGRectMake(rx, height, bgSize.width, bgSize.height);
        
        [_progressView setFrame:CGRectMake(self.ivBgView.frame.origin.x + 15, height + 12, iconSize.width, iconSize.height)];
        [_labFileName setFrame:CGRectMake(CGRectGetMaxX(_progressView.frame) + 10, height + 12, bgSize.width - iconSize.width - 36, 20)];
        [_labFileSize setFrame:CGRectMake(CGRectGetMaxX(_progressView.frame) + 10, height + 34, bgSize.width - iconSize.width - 36, 20)];
    }else{
        msgX = 15*2;

        [_progressView setFrame:CGRectMake(msgX, height + 12, 30, 40)];
        [_labFileName setFrame:CGRectMake(msgX+36, height + 12, bgSize.width - 36 - msgX, 18)];
        [_labFileSize setFrame:CGRectMake(msgX+36, height + 34, bgSize.width - 36 - msgX, 18)];

        [self.ivBgView setFrame:CGRectMake(15, height, bgSize.width, bgSize.height)];
    }
    height = bgSize.height+12;
    
    if (self.isRight && _progressView.progress>0&& _progressView.progress != 1) {
        CGSize cancelBtnSize = CGSizeMake(20, 20);
        cancelBtn.frame = CGRectMake(self.ivBgView.frame.origin.y - cancelBtnSize.width - 10, self.ivBgView.frame.size.height/2 , cancelBtnSize.width, cancelBtnSize.width);
        cancelBtn.hidden = NO;
    }else{
        cancelBtn.hidden = YES;
    }
    
//    CGFloat sh =  [self setSendStatus:self.ivBgView.frame];
    // 添加点踩和转人工
//    [self isAddBottomBgView:self.ivBgView.frame msgIsOneLine:NO];
    
    _tapView.frame = self.ivBgView.frame;
    
    if (!self.isRight && sobotConvertToString([model getModelDisplaySugestionText]).length > 0) {
        // 这里查看是否有关联问题
        CGFloat h = 0;
        CGFloat lineSpace = [ZCUITools zcgetChatLineSpacing];
        // 记录实际最大宽度
        CGFloat contentWidth = self.maxWidth;
        // 判断是否是一问多答中有关联问题
        _suglabel = [ZCChatBaseCell createRichLabel];
        _suglabel.delegate = self;
        UIColor *textColor = [ZCUITools zcgetLeftChatTextColor];
        UIColor *linkColor = [ZCUITools zcgetChatLeftLinkColor];
        if([ZCChatBaseCell isRightChat:model]){
            textColor = [ZCUITools zcgetRightChatTextColor];
            linkColor = [ZCUITools zcgetChatRightlinkColor];
        }
        [_suglabel setLinkColor:linkColor];
        [_suglabel setTextColor:textColor];
        if(model.displaySugestionattr!=nil){
            [ZCFileCell setDisplayAttributedString:model.displaySugestionattr label:_suglabel model:model guide:YES];
        }else{
            [ZCHtmlCore filterHtml:[model getModelDisplaySugestionText] result:^(NSString * _Nonnull text1, NSMutableArray * _Nonnull arr, NSMutableArray * _Nonnull links) {
                if (text1 != nil && text1.length > 0) {
                    self->_suglabel.attributedText =    [ZCHtmlFilter setGuideHtml:text1 attrs:arr view:self->_suglabel textColor:textColor textFont:[ZCUITools zcgetKitChatFont] linkColor:linkColor];
                }else{
                    self->_suglabel.attributedText =   [[NSAttributedString alloc] initWithString:@""];
                }
            }];
        }
        CGSize s = [_suglabel preferredSizeWithMaxWidth:self.maxWidth -45];
        // 添加行间距
        h = h + s.height + lineSpace;
        if(contentWidth < s.width){
            contentWidth = s.width;
        }
        // height +10是间距 和引导问题 ，左边加15间距
        CGRect f = CGRectMake(15+15, h - s.height - lineSpace + CGRectGetMaxY(_progressView.frame) +10, s.width, s.height);
        _suglabel.frame = f;
        [self.contentView addSubview:_suglabel];
  
        CGRect ivBgViewF = self.ivBgView.frame;
        ivBgViewF.size.height = ivBgViewF.size.height + s.height + 10;
        self.ivBgView.frame = ivBgViewF;
    }
    
    CGFloat sh =  [self setSendStatus:self.ivBgView.frame];
    // 添加点踩和转人工
    [self isAddBottomBgView:self.ivBgView.frame msgIsOneLine:NO];
    
    // 0,自己，1机器人，2客服
    if(self.isRight){
        // 右边气泡背景图片
        UIImage * bgImage = [ZCUITools zcuiGetBundleImage:@"zcicon_pop_green_normal_line"];
        bgImage=[bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(21, 21, 21, 21)];
        
        self.ivBgView.image = bgImage;
        self.ivBgView.backgroundColor = UIColorFromThemeColor(ZCBgSystemWhiteLightGrayColor);
        //设置尖角
        [self.ivLayerView setImage:bgImage];
    }else{
        self.ivBgView.image = nil;
        [self.ivBgView setBackgroundColor:[ZCUITools zcgetLeftChatColor]];
    }

    if([ZCUITools getZCThemeStyle] == ZCThemeStyle_Dark){
        self.ivBgView.backgroundColor = UIColorFromThemeColor(ZCBgSystemWhiteLightGrayColor);
    }
    self.ivBgView.contentMode = UIViewContentModeScaleToFill;
    
    
    // 设置尖角
    [self.ivLayerView setFrame:self.ivBgView.frame];
    CALayer *layer              = self.ivLayerView.layer;
    layer.frame                 = (CGRect){{0,0},self.ivLayerView.layer.frame.size};
    self.ivBgView.layer.mask = layer;
    [self.ivBgView setNeedsDisplay];
    
    self.frame = CGRectMake(0, 0, self.viewWidth, height +sh );
    
    return height + sh;
}


-(void)setProgress:(CGFloat) progress{
    [_progressView setProgress:progress];
    //    NSLog(@"progress === %f",progress);
    // 如果是右边用户正在发送的
    if (self.isRight && progress>0&& progress<1) {
        CGSize size = CGSizeMake(self.maxWidth, 60);
        int rx = self.viewWidth - size.width - 30 - 50 -18 -19;
        CGSize cancelBtnSize = CGSizeMake(20, 20);
        cancelBtn.frame = CGRectMake(self.ivBgView.frame.origin.x - cancelBtnSize.width - 10, self.ivBgView.frame.size.height/2 , cancelBtnSize.width, cancelBtnSize.width);
        cancelBtn.hidden = NO;
    }else{
        cancelBtn.hidden = YES;
    }
}


-(void)playVideo:(UIButton *)btn{
    if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]){
        //        [self.delegate touchLagerImageView:xh with:YES];
        [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeTouchImageYES obj:nil];
    }
    UIWindow *window = [[ZCToolsCore getToolsCore] getCurWindow];
    ZCVideoPlayer *player = [[ZCVideoPlayer alloc] initWithFrame:window.bounds withShowInView:window url:[NSURL URLWithString:self.tempModel.richModel.richmoreurl] Image:nil];
    [player showControlsView];
    
}
// 点击查看大图
-(void) tap:(UITapGestureRecognizer *)recognizer{
    if(self.tempModel.richModel.fileType == 5){
        [self playVideo:nil];
        return;
    }
    //        [SobotLog logDebug:@"查看大图：%@",self.tempModel.richModel.richmoreurl];
    if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]){
        [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeItemOpenFile obj:nil];
        //                [_delegate itemOnClick:_tempModel clickType:SobotCellClickReSend];
    }
}


-(void)cancelSendMsg:(UIButton *)sender{
    //    NSLog(@"取消发送文件\\");
    if (self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]) {
        [self.delegate cellItemClick:_model type:ZCChatCellClickTypeItemCancelFile obj:_model];
    }
    cancelBtn.hidden = YES;
    cancelBtn = nil;
}

-(void)resetCellView{
    //    cancelBtn = nil;
    [super resetCellView];
    _suglabel.text = @"";
}


+(CGFloat)getCellHeight:(ZCLibMessage *)model time:(NSString *)showTime viewWith:(CGFloat)width{
    CGFloat height = [super getCellHeight:model time:showTime viewWith:width];
    height = height +  [ZCChatBaseCell getStatusHeight:model];
    height=height+FileHeight + 20;
    
    // 判断是否是一问多答中有关联问题
       if(sobotConvertToString([model getModelDisplaySugestionText]).length > 0){
           ZCMLEmojiLabel *slabel = [ZCChatBaseCell createRichLabel];
           UIColor *textColor = [ZCUITools zcgetLeftChatTextColor];
           UIColor *linkColor = [ZCUITools zcgetChatLeftLinkColor];
           if(model.displaySugestionattr!=nil){
               [ZCFileCell setDisplayAttributedString:model.displaySugestionattr label:slabel model:model guide:YES];
           }else{
               [ZCHtmlCore filterHtml:[model getModelDisplaySugestionText] result:^(NSString * _Nonnull text1, NSMutableArray * _Nonnull arr, NSMutableArray * _Nonnull links) {
                   if (text1 != nil && text1.length > 0) {
                       slabel.attributedText =    [ZCHtmlFilter setGuideHtml:text1 attrs:arr view:slabel textColor:textColor textFont:[ZCUITools zcgetKitChatFont] linkColor:linkColor];
                   }else{
                       slabel.attributedText =   [[NSAttributedString alloc] initWithString:@""];
                   }
               }];
           }
           CGSize s = [slabel preferredSizeWithMaxWidth:width-70-45];
           height = height + s.height + 10;
       }
    
    return height;
}

#pragma mark EmojiLabel链接点击事件
// 链接点击
-(void)attributedLabel:(ZCTTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url{
    // 此处得到model 对象对应的值
    NSString *textStr = label.text;
    
    if (label.text) {
        if(url.absoluteString && [url.absoluteString hasPrefix:@"sobot:"]){
            int index = [[url.absoluteString stringByReplacingOccurrencesOfString:@"sobot://" withString:@""] intValue];
            if(index > 0 && self.tempModel.richModel.suggestionArr.count>=index){
                textStr = [self.tempModel.richModel.suggestionArr objectAtIndex:index-1][@"question"];
            }
        }
        
    }
    
    
    [self doClickURL:url.absoluteString text:textStr];
}

// 链接点击
-(void)ZCMLEmojiLabel:(ZCMLEmojiLabel *)emojiLabel didSelectLink:(NSString *)link withType:(ZCMLEmojiLabelLinkType)type{
    [self doClickURL:link text:@""];
}

// 链接点击
-(void)doClickURL:(NSString *)url text:(NSString * )htmlText{
    if(url){
        url=[url stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        // 用户引导说辞的分类的点击事件
        if([url hasPrefix:@"sobot:"]){
            if([url hasPrefix:@"sobot://showallsensitive"]){
                if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]){
                    [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeShowSensitive obj:nil];
                }
                return;
            }
            int index = [[url stringByReplacingOccurrencesOfString:@"sobot://" withString:@""] intValue];
            
            if(index > 0 && self.tempModel.richModel.suggestionArr.count>=index){
                if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]){
                    [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeItemChecked obj:[NSString stringWithFormat:@"%d",index-1]];
                }
                return;
            }
            
        }else if ([url hasPrefix:@"robot:"]){
            // 处理 机器人回复的 技能组点选事件
            
//          3.0.8 如果当前 已转人工 ， 不可点击
            if([self getZCLibConfig].isArtificial){
                return;
            }
            
            int index = [[url stringByReplacingOccurrencesOfString:@"robot://" withString:@""] intValue];
            if(index > 0 && self.tempModel.groupList.count>=index){
                if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]){
                    [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeGroupItemChecked obj:[NSString stringWithFormat:@"%d",index-1]];
                }
            }
        }else if([url hasPrefix:@"zc_refresh_newdata"]){
            if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]){
                [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeNewDataGroup obj:url];
            }
        }else{
            if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemLinkClick:type:obj:)]){
                [self.delegate cellItemLinkClick:htmlText type:ZCChatCellClickTypeOpenURL obj:url];
            }
        }
    }
}


-(ZCLibConfig *) getZCLibConfig{
    //    return [ZCIMChat getZCIMChat].config;
    return [[ZCPlatformTools sharedInstance] getPlatformInfo].config;
}

#pragma mark - gesture delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isMemberOfClass:[ZCMLEmojiLabel class]]){
        return NO;
    }
    return YES;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
