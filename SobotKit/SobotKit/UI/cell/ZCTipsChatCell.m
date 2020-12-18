//
//  ZCTipsChatCell.m
//  SobotApp
//
//  Created by 张新耀 on 15/10/15.
//  Copyright © 2015年 com.sobot.chat. All rights reserved.
//

#import "ZCTipsChatCell.h"

#import "ZCLibGlobalDefine.h"
#import "ZCUIColorsDefine.h"


#import "ZCMLEmojiLabel.h"
#import "ZCIMChat.h"
#import "ZCPlatformTools.h"


#import "ZCHtmlCore.h"
#import "ZCHtmlFilter.h"

@interface ZCTipsChatCell()<ZCMLEmojiLabelDelegate>{
    
}

@end

@implementation ZCTipsChatCell{

    ZCMLEmojiLabel *_lblTextMsg;
    UIImageView     *_lineView;
    CGPoint centerX;

}


- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        _lineView = [[UIImageView alloc] init];
        [_lineView setBackgroundColor:UIColorFromThemeColor(ZCBgLineColor)];
        [self.contentView insertSubview:_lineView belowSubview:self.ivBgView];
        _lineView.hidden = YES;
    }
    return self;
}



- (ZCMLEmojiLabel *)emojiLabel
{
    if (!_lblTextMsg) {
        _lblTextMsg = [ZCMLEmojiLabel new];
        _lblTextMsg.numberOfLines = 0;
        _lblTextMsg.font = ZCUIFont12;
        _lblTextMsg.delegate = self;
        _lblTextMsg.lineBreakMode = NSLineBreakByTruncatingTail;
        _lblTextMsg.textColor = [UIColor whiteColor];
        _lblTextMsg.backgroundColor = [UIColor clearColor];
        
        //        _lblTextMsg.textInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        
        _lblTextMsg.isNeedAtAndPoundSign = NO;
        _lblTextMsg.disableEmoji = NO;
        _lblTextMsg.lineSpacing = 3.0f;
        _lblTextMsg.verticalAlignment = ZCTTTAttributedLabelVerticalAlignmentCenter;
//        _lblTextMsg.textAlignment = NSTextAlignmentCenter;
//        [_lblTextMsg setLinkColor:[ZCUITools zcgetChatLeftLinkColor]];
        [self.contentView addSubview:_lblTextMsg];
    }
    return _lblTextMsg;
}

-(CGFloat) InitDataToView:(ZCLibMessage *) model time:(NSString *) showTime{
    [self resetCellView];
    // 添加时间（触发新会话时）
    CGFloat timeHeight = 12 ;
    if(![@"" isEqual:zcLibConvertToString(showTime)]){
        [self.lblTime setText:showTime];
        [self.lblTime setFrame:CGRectMake(0, 0, self.viewWidth, 30)];
        self.lblTime.hidden=NO;
        timeHeight = 30;
    }
    
    // 调整提示cell的行间距
    CGFloat cellHeight = timeHeight;
    
//    self.ivBgView.layer.cornerRadius = 12;
//    self.ivBgView.layer.masksToBounds = YES;
    
    // 设置提示气泡的背景颜色
    if(model.tipStyle == 2){
        _lineView.hidden = NO;
        [self.emojiLabel setTextColor:[ZCUITools zcgetTimeTextColor]];
        [self.ivBgView setBackgroundColor:[ZCUITools zcgetBackgroundColor]];
    }else{
        _lineView.hidden = YES;
        [self.emojiLabel setTextColor:UIColorFromThemeColor(ZCTextSubColor)];
//        [self.emojiLabel setTextColor:[UIColor blueColor]];
        [self.ivBgView setBackgroundColor:[ZCUITools zcgetBgTipAirBubblesColor]];
//        self.ivBgView.backgroundColor = UIColorFromRGB(0xFFF8F9FA); FFACB5C4
    }
    
    if(model){
        CGRect msgF = CGRectMake(0, cellHeight+5, self.viewWidth-40, 0);
        [_lblTextMsg setFrame:msgF];
        NSString *temp = [NSString stringWithFormat:@"%@", [NSString stringWithFormat:@"%@,%@ %@",ZCSTLocalString(@"暂时无法转接人工客服"),ZCSTLocalString(@"您可以"),ZCSTLocalString(@"留言")]];
        if(
           (zcLibConvertToString(model.sysTips).length >0) &&
           ([zcLibConvertToString(model.sysTips) hasSuffix:ZCSTLocalString(@"您已完成评价")] ||
           [zcLibConvertToString(model.sysTips) hasSuffix:ZCSTLocalString(@"咨询后才能评价服务质量")] ||
            [zcLibConvertToString(model.sysTips) hasPrefix:ZCSTLocalString(@"您好,本次会话已结束")] ||
            [zcLibConvertToString(model.sysTips) hasPrefix:temp]||
            [zcLibConvertToString(model.sysTips) hasPrefix:ZCSTLocalString(@"暂无客服在线")]) ){
            // 处理动画样式
            [self setTipCellAnimateTransformWith:model];
//
//
//            // 留言标签的处理
//            NSString *tempStr = model.sysTips;
//            tempStr = [tempStr stringByReplacingOccurrencesOfString:@"[" withString:@""];
//            tempStr = [tempStr stringByReplacingOccurrencesOfString:@"]" withString:@""];
//
//            [_lblTextMsg setLinkColor:[ZCUITools zcgetRightChatColor]];
//            _lblTextMsg.text = tempStr;
//
//
//            if ([tempStr hasSuffix:ZCSTLocalString(@"留言")]) {
//
//
//                [_lblTextMsg addLinkToURL:[NSURL URLWithString:ZCSTLocalString(@"留言")] withRange:NSMakeRange(tempStr.length-ZCSTLocalString(@"留言").length, ZCSTLocalString(@"留言").length)];
//
            }
//
//
//        }else{
            [self HandleHTMLTagsWith:model];
//        }
        
        CGSize optimalSize = [[self emojiLabel] preferredSizeWithMaxWidth:self.viewWidth - 40];
//        NSLog(@"一次计算文本的高度%f",optimalSize.height);
        msgF.size.height = optimalSize.height;
        msgF.size.width  = optimalSize.width;
        [_lblTextMsg setFrame:msgF];
        
        
        CGRect lf      = _lblTextMsg.frame;
        lf.origin.x    = self.viewWidth/2-lf.size.width/2;
        
        [_lblTextMsg setFrame:lf];
       
        lf.origin.x=lf.origin.x-15;
        lf.origin.y=lf.origin.y - 3;
        lf.size.width=lf.size.width+30;
        lf.size.height=lf.size.height+6;
        [self.ivBgView setFrame:lf];
        
        if(model.tipStyle == 2){
            CGFloat x = self.viewWidth * 13/75;
            CGRect lineF = CGRectMake(x, 0, self.viewWidth-2*x, 0.75f);
            lineF.origin.y = lf.origin.y + (lf.size.height/2);
            [_lineView setFrame:lineF];
        }
        
        self.ivBgView.layer.cornerRadius=12.0f;
        self.ivBgView.layer.masksToBounds=YES;
        
        cellHeight=lf.size.height + lf.origin.y ;
//        NSLog(@"第一次计算之后的cell 搞%f",cellHeight);
        self.frame=CGRectMake(0, 0, self.viewWidth, cellHeight + 10 +3);
    
    }
    
//    NSLog(@"再加上15%f",cellHeight);
    return cellHeight +3;
}


- (void)setTipCellAnimateTransformWith:(ZCLibMessage *)model{
    //*2.0.0版本新加 新会话键盘样式出现时，未发送成功的消息不能在发送，提示离线或者会话结束。
    if ((model.tipStyle>0 && !model.isRead)|| ((model.tipStyle==2042 || model.tipStyle == 2044) && !model.isRead)){
        [UIView animateWithDuration:0.1 animations:^{
            
            self.ivBgView.layer.transform = CATransform3DMakeTranslation(-20, 0, 0);
            _lblTextMsg.layer.transform = CATransform3DMakeTranslation(-20, 0, 0);
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.1 animations:^{
                
                self.ivBgView.layer.transform = CATransform3DMakeTranslation(20, 0, 0);
                _lblTextMsg.layer.transform = CATransform3DMakeTranslation(20, 0, 0);
            } completion:^(BOOL finished) {
                model.isRead = YES;
                [UIView animateWithDuration:0.1 animations:^{
                    
                    self.ivBgView.layer.transform = CATransform3DMakeTranslation(-20, 0, 0);
                    _lblTextMsg.layer.transform = CATransform3DMakeTranslation(-20, 0, 0);
                } completion:nil];
            }];
            
        }];
        
        
    }

}


- (void)turnLeverMessageVC{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]) {
        [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeLeaveMessage obj:_lblTextMsg];
    }
}
- (void)turnLeverMsgRecordVC{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]) {
        [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeLeaveRecordPage obj:_lblTextMsg];
    }
}


-(void)resetCellView{
    [super resetCellView];
    
    [self emojiLabel].text = @"";
    [self.lblNickName setText:@""];
}


#pragma mark EmojiLabel链接点击事件
// 链接点击
-(void)attributedLabel:(ZCTTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url{

    if ([zcLibConvertToString(label.text) hasSuffix:ZCSTLocalString(@"留言")] && (url.absoluteString.length ==0 || [ZCSTLocalString(@"留言") isEqual:url.absoluteString] )) {
        [self turnLeverMessageVC];
    }else if ([zcLibConvertToString(label.text) hasSuffix:ZCSTLocalString(@"您的留言状态有 更新")] && (url.absoluteString.length ==0 || [ZCSTLocalString(@"您的留言状态有 更新") isEqual:url.absoluteString] || [ZCSTLocalString(@"更新") isEqual:url.absoluteString])){
        [self turnLeverMsgRecordVC];
    }else{
         [self doClickURL:url.absoluteString text:@""];
    }
    
}

// 链接点击
-(void)ZCMLEmojiLabel:(ZCMLEmojiLabel *)emojiLabel didSelectLink:(NSString *)link withType:(ZCMLEmojiLabelLinkType)type{
    [self doClickURL:link text:@""];
}

// 链接点击
-(void)doClickURL:(NSString *)url text:(NSString * )htmlText{
    if(url){
        url=[url stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        if([url hasPrefix:@"sobot://newsessionchat"]){
            if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]){
                [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeNewSession obj:@""];
            }
        }else if([url hasPrefix:@"sobot:"]){
            int tag=[[url stringByReplacingOccurrencesOfString:@"sobot://" withString:@""] intValue];
            if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]){
                [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeItemChecked obj:[NSString stringWithFormat:@"%d",tag]];
            }
        }else{
            if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemLinkClick:type:obj:)]){
                [self.delegate cellItemLinkClick:@"" type:ZCChatCellClickTypeOpenURL obj:url];
            }
        }
    }
}


#pragma mark - gesture delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return ![self.emojiLabel containslinkAtPoint:[touch locationInView:self.emojiLabel]];
}


-(ZCLibConfig *) getZCLibConfig{
    return [[ZCPlatformTools sharedInstance] getPlatformInfo].config;//[ZCIMChat getZCIMChat].libConfig;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+(CGFloat) getCellHeight:(ZCLibMessage *)model time:(NSString *)showTime viewWith:(CGFloat)viewWidth{
    // 添加时间（触发新会话时）
    CGFloat timeHeight = 12 ;
    if(![@"" isEqual:zcLibConvertToString(showTime)]){
        timeHeight = 30;
    }
    
    if(model){
        timeHeight = timeHeight + 10;
        static ZCMLEmojiLabel *tempLabel = nil;
        if (!tempLabel) {
            tempLabel = [ZCMLEmojiLabel new];
            tempLabel.numberOfLines = 0;
            tempLabel.font = ZCUIFont12;
            tempLabel.backgroundColor = [UIColor clearColor];
            tempLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            tempLabel.textColor = [UIColor whiteColor];
            tempLabel.isNeedAtAndPoundSign = YES;
            tempLabel.disableEmoji = NO;
            tempLabel.lineSpacing = 3.0f;
            tempLabel.verticalAlignment = ZCTTTAttributedLabelVerticalAlignmentCenter;
        }
        
        // 处理HTML标签
        NSString  *text = [ZCTipsChatCell getSysTipsText:model];
        
        tempLabel.text = text;
        
        CGSize optimalSize = [tempLabel preferredSizeWithMaxWidth:viewWidth - 40];
//        NSLog(@"计算后文本的高度%f",optimalSize.height);
        timeHeight = timeHeight + optimalSize.height + 10;
    }

    return timeHeight +3;
}


// 处理标签
- (void)HandleHTMLTagsWith:(ZCLibMessage *) model{
    NSString  *text = [ZCTipsChatCell getSysTipsText:model];
  
    text = [text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
//    [_lblTextMsg setLinkColor:[ZCUITools zcgetChatLeftLinkColor]];
//    [_lblTextMsg setLinkColor:[UIColor redColor]];
    
    
    [ZCHtmlCore filterHtml:text result:^(NSString * _Nonnull text1, NSMutableArray * _Nonnull arr, NSMutableArray * _Nonnull links) {
        // zcgetTipLayerTextColor  zcgetLeftChatTextColor
        if (text1 != nil && text1.length > 0) {
            if ([text1 hasPrefix:[NSString stringWithFormat:@"%@",ZCSTLocalString(@"您好，客服")]]) {
               [_lblTextMsg setLinkColor:UIColorFromThemeColor(ZCTextSubColor)];
            }
//             _lblTextMsg.attributedText = [ZCHtmlFilter setHtml:text1 attrs:arr view:_lblTextMsg textColor:[ZCUITools zcgetTipLayerTextColor] textFont:[ZCUITools zcgetListKitDetailFont] linkColor:[ZCUITools zcgetChatLeftLinkColor]];FFACB5C4
//            _lblTextMsg.attributedText =
            [ZCHtmlFilter setHtml:text1 attrs:arr view:_lblTextMsg textColor:[ZCUITools zcgetTipLayerTextColor] textFont:ZCUIFont12 linkColor:[ZCUITools zcgetChatLeftLinkColor]];
            
        }else{
             _lblTextMsg.attributedText = [[NSAttributedString alloc] initWithString:@""];
        }
       
    }];
    
    if ([zcLibConvertToString( model.sysTips) hasPrefix:zcLibConvertToString([self getZCLibConfig].userOutWord)] || [zcLibConvertToString( model.sysTips) hasPrefix:zcLibConvertToString([self getZCLibConfig].adminNonelineTitle)]) {
        [self setTipCellAnimateTransformWith:model];
    }
    
    if ([zcLibConvertToString(text) hasSuffix:ZCSTLocalString(@"您的留言状态有 更新")]) {
        NSString *update = ZCSTLocalString(@"更新");
        [_lblTextMsg addLinkToURL:[NSURL URLWithString:update] withRange:NSMakeRange(ZCSTLocalString(@"您的留言状态有 更新").length - update.length, update.length)];
        
        [self.ivBgView setBackgroundColor:[ZCUITools zcgetLeftChatColor]];
    }

}


+(NSString *)getSysTipsText:(ZCLibMessage *) model{
    // 处理HTML标签
    NSString  *text = [ZCHtmlCore filterHTMLTag:zcLibConvertToString(model.sysTips)] ;
    while ([zcLibConvertToString(text) hasPrefix:@"\n"]) {
        text=[text substringWithRange:NSMakeRange(1, text.length-1)];
    }
    
    if ([zcLibConvertToString(text) hasPrefix:[NSString stringWithFormat:@"%@",ZCSTLocalString(@"您好，客服")]]) {
        // 留言标签的处理
//        NSString nikeNameStr = ZCSTLocalString(@"昵称");
        text = [text stringByReplacingOccurrencesOfString:@"[" withString:@"<a href='昵称'>"];
        text = [text stringByReplacingOccurrencesOfString:@"]" withString:@"</a>"];
    }
    
    if ([zcLibConvertToString(text) hasSuffix:ZCSTLocalString(@"留言")]) {
        // 留言标签的处理
        text = [text stringByReplacingOccurrencesOfString:ZCSTLocalString(@"留言") withString:[NSString stringWithFormat:@"<a href='%@'>%@</a>",ZCSTLocalString(@"留言"),ZCSTLocalString(@"留言")]];
    }
    
    if ([zcLibConvertToString(text) hasSuffix:ZCSTLocalString(@"重建会话")]) {
        // 如果有重建会话的时候，点击重新开始会话
        text = [text stringByReplacingOccurrencesOfString:ZCSTLocalString(@"重建会话") withString:[NSString stringWithFormat:@"<a href='sobot://newsessionchat'>%@</a>",ZCSTLocalString(@"重建会话")]];
    }
    
    return text;
}


@end
