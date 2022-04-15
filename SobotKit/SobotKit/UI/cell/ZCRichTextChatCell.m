//
//  ZCTextChatCell.m
//  SobotApp
//
//  Created by 张新耀 on 15/9/15.
//  Copyright (c) 2015年 com.sobot.chat. All rights reserved.
//

#import "ZCRichTextChatCell.h"
//#import "ZCUIXHImageViewer.h"
#import "SobotXHImageViewer.h"
//#import "ZCUIImageView.h"
#import "SobotImageView.h"
#import "ZCLibGlobalDefine.h"
#import "ZCActionSheet.h"
#import "ZCUIToastTools.h"
#import "ZCUIColorsDefine.h"
#import "ZCPlatformTools.h"
#import "ZCIMChat.h"
#import "ZCHtmlCore.h"
#import "ZCLocalStore.h"
#import "ZCToolsCore.h"
#import "ZCUICore.h"

#define MidImageHeight 110
@interface ZCRichTextChatCell()<ZCMLEmojiLabelDelegate,SobotXHImageViewerDelegate,ZCActionSheetDelegate>{
    NSString    *callURL;
    ZCMLEmojiLabel *_lblTextMsg;
    SobotImageView *_middleImageView; // 图片
    ZCMLEmojiLabel *_sugesstionLabel; // 展开
    ZCMLEmojiLabel *_lookMoreLabel; // 展开
    UIView       * _lineView; // 线条
    
    UIMenuController *menuController;
    NSString *_coderURLStr;
    SobotXHImageViewer *_imageViewer;
}

@end


@implementation ZCRichTextChatCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        UITapGestureRecognizer *tapG = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap)];
        tapG.delegate = self;
        [self.ivBgView addGestureRecognizer:tapG];
        
        
    }
    return self;
}


- (void)tap
{
    //    NSLog(@"tapped");
}

#pragma mark - gesture delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return ![self.emojiLabel containslinkAtPoint:[touch locationInView:self.emojiLabel]];
}

#pragma mark - getter
- (ZCMLEmojiLabel *)emojiLabel // 中间的消息体
{
    if (!_lblTextMsg) {
        _lblTextMsg = [[ZCMLEmojiLabel alloc] initWithFrame:CGRectZero];
        _lblTextMsg.numberOfLines = 0;
        _lblTextMsg.font = [ZCUITools zcgetKitChatFont];
        _lblTextMsg.delegate = self;
        _lblTextMsg.lineBreakMode = NSLineBreakByTruncatingTail;
        _lblTextMsg.textColor = [UIColor whiteColor];
        _lblTextMsg.backgroundColor = [UIColor clearColor];
        
        //        _lblTextMsg.textInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        
        _lblTextMsg.isNeedAtAndPoundSign = NO;
        _lblTextMsg.disableEmoji = NO;
        
        _lblTextMsg.lineSpacing = 3.0f;
        
        _lblTextMsg.verticalAlignment = ZCTTTAttributedLabelVerticalAlignmentCenter;
        [self.contentView addSubview:_lblTextMsg];
    }
    return _lblTextMsg;
}
- (ZCMLEmojiLabel *)sugesstionLabel // 中间的消息体
{
    if (!_sugesstionLabel) {
        _sugesstionLabel = [[ZCMLEmojiLabel alloc] initWithFrame:CGRectZero];
        _sugesstionLabel.numberOfLines = 0;
        _sugesstionLabel.font = [ZCUITools zcgetKitChatFont];
        _sugesstionLabel.delegate = self;
        _sugesstionLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _sugesstionLabel.textColor = [UIColor whiteColor];
        _sugesstionLabel.backgroundColor = [UIColor clearColor];
        
        //        _lblTextMsg.textInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        
        _sugesstionLabel.isNeedAtAndPoundSign = NO;
        _sugesstionLabel.disableEmoji = NO;
        
        _sugesstionLabel.lineSpacing = 3.0f;
        
        _sugesstionLabel.verticalAlignment = ZCTTTAttributedLabelVerticalAlignmentCenter;
        [self.contentView addSubview:_sugesstionLabel];
    }
    return _sugesstionLabel;
}

-(SobotImageView *)middleImageView{
    if(!_middleImageView){
        _middleImageView=[[SobotImageView alloc] init];
        [_middleImageView setBackgroundColor:[UIColor clearColor]];
        [_middleImageView setContentMode:UIViewContentModeScaleAspectFill];
        _middleImageView.layer.masksToBounds=YES;
        [self.contentView addSubview:_middleImageView];
    }
    return _middleImageView;
}

- (ZCMLEmojiLabel *)lookMoreLabel
{
    if (!_lookMoreLabel) {
        _lookMoreLabel = [[ZCMLEmojiLabel alloc] initWithFrame:CGRectZero];
        _lookMoreLabel.numberOfLines = 0;
        _lookMoreLabel.font = ZCUIFont12;
        _lookMoreLabel.delegate = self;
        _lookMoreLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _lookMoreLabel.textColor = [UIColor whiteColor];
        _lookMoreLabel.backgroundColor = [UIColor clearColor];
        //        _sugguestLabel.textInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        
        _lookMoreLabel.isNeedAtAndPoundSign = NO;
        _lookMoreLabel.disableEmoji = NO;
        _lookMoreLabel.lineSpacing = 3.0f;
        
        //        _lookMoreLabel.verticalAlignment = ZCTTTAttributedLabelVerticalAlignmentCenter;
        [self.contentView addSubview:_lookMoreLabel];
    }
    return _lookMoreLabel;
}


#pragma mark -- 长按复制
- (void)doLongPress:(UIGestureRecognizer *)recognizer{
    if (recognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    [self didChangeBgColorWithsIsSelect:YES];
    
    [self becomeFirstResponder];
    menuController = [UIMenuController sharedMenuController];
    UIMenuItem *copyItem = [[UIMenuItem alloc]initWithTitle:ZCSTLocalString(@"复制") action:@selector(doCopy)];
    [menuController setMenuItems:@[copyItem]];
    [menuController setArrowDirection:(UIMenuControllerArrowDefault)];
    // 设置frame cell的位置
    CGRect tf     = _lblTextMsg.frame;
    CGRect rect = CGRectMake(tf.origin.x, tf.origin.y, tf.size.width, 1);
    
    [menuController setTargetRect:rect inView:self];
    
    [menuController setMenuVisible:YES animated:YES];
}

- (void)willHideEditMenu:(id)sender{
    [self didChangeBgColorWithsIsSelect:NO];
}

- (void)didChangeBgColorWithsIsSelect:(BOOL)isSelected{
    
    if (isSelected) {
        if (self.isRight) {
            [self.ivBgView setBackgroundColor:[ZCUITools zcgetRightChatSelectdeColor]];
        }else{
            [self.ivBgView setBackgroundColor:[ZCUITools zcgetLeftChatSelectedColor]];
        }
    }else{
        if (self.isRight) {
            // 右边气泡绿色
            [self.ivBgView setBackgroundColor:[ZCUITools zcgetRightChatColor]];
        }else{
            // 左边的气泡颜色
            [self.ivBgView setBackgroundColor:[ZCUITools zcgetLeftChatColor]];
        }
        [menuController setTargetRect:CGRectMake(0, 0, 0, 0) inView:nil];
    }
    [self.ivBgView setNeedsDisplay];
    
}

//复制
-(void)doCopy{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:self.tempModel.richModel.msg];
    if (self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]) {
        [self.delegate cellItemClick:nil type:ZCChatCellClickTypeShowToast obj:nil];
    }
    [self didChangeBgColorWithsIsSelect:NO];
}


#pragma mark - UIMenuController 必须实现的两个方法
- (BOOL)canBecomeFirstResponder{
    return YES;
}

/*
 *  根据action,判断UIMenuController是否显示对应aciton的title
 */
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    if (action == @selector(doCopy) ) {
        return YES;
    }
    return NO;
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

-(CGFloat) InitDataToView:(ZCLibMessage *)model time:(NSString *)showTime{
    
    CGFloat bgY=[super InitDataToView:model time:showTime];
    
    CGFloat maxWidth = self.viewWidth - 100;
    // 有顶 踩
//    if (model.senderType == 1 && (model.commentType == 1 || model.commentType == 2||model.commentType == 3|| model.commentType == 4)) {
//        maxWidth = self.viewWidth - 90 - 32 - 50;
//
//    }
    
    if (model.leaveMsgFlag == 1) {
        maxWidth = maxWidth - 20;
    }
    
    [self emojiLabel].text = @"";
    
    if (model.richModel.msgType == 0) {
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(doLongPress:)];
        
        [self.emojiLabel addGestureRecognizer:longPress];
        
        // 添加复制框消失的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willHideEditMenu:) name:UIMenuControllerDidHideMenuNotification object:nil];
    }
    
    CGFloat rw = maxWidth;
    CGFloat height = 0;
    
    
    CGRect msgF = CGRectZero;
    CGRect sugestionF = CGRectZero;
    CGRect imgF = CGRectZero;
    CGRect lineF = CGRectZero;
    CGRect moreF = CGRectZero;
    
    if ([ZCChatBaseCell getStatusHeight:model] >0) {
        // 显示顶踩 固定最大宽度
        rw = maxWidth;
    }
    
    for (UIView *v in self.ivBgView.subviews) {
        [v removeFromSuperview];
    }
    
    if(model.richModel.msgType == 15 && model.richModel.multiModel.templateIdType == 3){
        NSMutableDictionary * detailDict = model.richModel.multiModel.interfaceRetList.firstObject; // 多个
        model.richModel.richpricurl = sobotConvertToString(detailDict[@"thumbnail"]);
        model.richModel.richmoreurl = sobotConvertToString(detailDict[@"anchor"]);
    }
    
#pragma mark  -- 图片
    // 处理图片  当前的图片高度固定110
    if(model.richModel.msgType>0 && !sobotIsNull(model.richModel.richpricurl)){
        [[self middleImageView] loadWithURL:[NSURL URLWithString:sobotUrlEncodedString(model.richModel.richpricurl)] placeholer:[ZCUITools zcuiGetBundleImage:@"zcicon_default_goods_1"] showActivityIndicatorView:YES];
        [self middleImageView].hidden=NO;
        height = height + 15;
        [self middleImageView].userInteractionEnabled=YES;
        UITapGestureRecognizer *labelTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imgTouchUpInside:)];
        [[self middleImageView] addGestureRecognizer:labelTapGestureRecognizer];
        imgF = CGRectMake(GetCellItemX(self.isRight), height, rw, MidImageHeight);
        [self.middleImageView setFrame:imgF];
        height = height + MidImageHeight + 10 + Spaceheight;
    }else{
        height = height + 10;
    }
    
    
#pragma mark 标题+内容
    NSString *text = sobotConvertToString([model getModelDisplayText]);
    if(text.length == 0){
        _lblTextMsg.text = @"";
    }else{
        UIColor *textColor = [ZCUITools zcgetLeftChatTextColor];
        UIColor *linkColor = [ZCUITools zcgetChatLeftLinkColor];
        if([ZCChatBaseCell isRightChat:model]){
            textColor = [ZCUITools zcgetRightChatTextColor];
            linkColor = [ZCUITools zcgetChatRightlinkColor];
        }
        if(model.displayMsgAttr!=nil){
            [ZCChatBaseCell setDisplayAttributedString:model.displayMsgAttr label:_lblTextMsg  model:model guide:NO];
            
        }else{
            [ZCHtmlCore filterHtml:text result:^(NSString * _Nonnull text1, NSMutableArray * _Nonnull arr, NSMutableArray * _Nonnull links) {
                if (text1 != nil && text1.length > 0) {
                    NSMutableAttributedString *attr;
//                    NSString *sugesstionText = sobotConvertToString([model isRobotGuide]);
                    UIFont *font = [ZCUITools zcgetKitChatFont];
                    if(model.isRobotGuide){
                        font = ZCUIFontBold14;
                    }
                    attr   =  [ZCHtmlFilter setHtml:text1 attrs:arr view:_lblTextMsg textColor:textColor textFont:font linkColor:linkColor];
                    
                    if(sobotConvertToString(model.richModel.question).length > 0){
                        NSRange r = [text1 rangeOfString:sobotConvertToString(model.richModel.question)];

                        [attr addAttribute:NSForegroundColorAttributeName value:textColor range:r];
                        
                    }
                    _lblTextMsg.attributedText =   attr;
                }else{
                    _lblTextMsg.attributedText =   [[NSAttributedString alloc] initWithString:@""];
                }
            }];
        }
    }
    CGSize msgSize = [self.emojiLabel preferredSizeWithMaxWidth:maxWidth];
    
//    NSLog(@"...%f",size.height);
    CGSize size;
    if (msgSize.height > 25) {
        size.height = msgSize.height;
        size.width = maxWidth;
    }else{
        size = msgSize;
    }

    if (sobotIsNull(model.richModel.richmoreurl) && sobotIsNull(model.richModel.richpricurl)  && [ZCChatBaseCell getStatusHeight:model] == 0) {
        rw = size.width + 5;
    }
    
    // 如果显示图片，文本最多显示3行
    if(model.richModel.msgType>0 && !sobotIsNull(model.richModel.richpricurl)){
        // 有标题的需要显示4行，不带标题最多显示3行
        if (sobotConvertToString(model.richModel.question).length > 0) {
            if (size.height > 110) {
                size.height = 110;
            }
        }else{
            if(size.height>70){
                size.height = 70;
            }
        }
    }
    
    
    msgF = CGRectMake(GetCellItemX(self.isRight), height, size.width, size.height);
    [[self emojiLabel] setFrame:msgF];
//    [self emojiLabel].backgroundColor = [UIColor redColor];
    
    height = height + size.height + 10 + Spaceheight;
    
    NSString *sugesstionText = sobotConvertToString([model getModelDisplaySugestionText]);
    if(sobotConvertToString(sugesstionText).length > 0){
        [self sugesstionLabel].hidden = NO;
        UIColor *textColor = [ZCUITools zcgetLeftChatTextColor];
        UIColor *linkColor = [ZCUITools zcgetChatLeftLinkColor];
        if([ZCChatBaseCell isRightChat:model]){
            textColor = [ZCUITools zcgetRightChatTextColor];
            linkColor = [ZCUITools zcgetChatRightlinkColor];
        }
        if(model.displaySugestionattr!=nil){
//            NSMutableAttributedString* attributedString = [model.displaySugestionattr mutableCopy];
            [ZCChatBaseCell setDisplayAttributedString:model.displaySugestionattr label:[self sugesstionLabel]  model:model guide:YES];
            
        }else{
            [ZCHtmlCore filterHtml:[model getModelDisplaySugestionText] result:^(NSString * _Nonnull text1, NSMutableArray * _Nonnull arr, NSMutableArray * _Nonnull links) {
                if (text1 != nil && text1.length > 0) {
                    [self sugesstionLabel].attributedText =    [ZCHtmlFilter setGuideHtml:text1 attrs:arr view:[self sugesstionLabel] textColor:textColor textFont:[ZCUITools zcgetKitChatFont] linkColor:linkColor];
                }else{
                    [self sugesstionLabel].attributedText =   [[NSAttributedString alloc] initWithString:@""];
                }
            }];
        }


        CGSize sugesstionSize = [self.sugesstionLabel preferredSizeWithMaxWidth:maxWidth];
        
            // 添加引导行间距
            CGFloat xlineSpace = [ZCUITools zcgetKitChatFont].lineHeight;
        sugestionF = CGRectMake(GetCellItemX(self.isRight), height - xlineSpace/2 , sugesstionSize.width, sugesstionSize.height);
        
        if (model.richModel.msgType == 15 || model.richModel.msgType == 3) {
            sugesstionSize.height = 0;
            [self sugesstionLabel].hidden = YES;
            height = height - 10;

        }else{
            [self sugesstionLabel].hidden = NO;
            [[self sugesstionLabel] setFrame:sugestionF];
            height = height + sugesstionSize.height +10 + xlineSpace;

        }


        
        if(rw < sugesstionSize.width){
            rw = sugesstionSize.width ;
        }
        
//        没有 换一组
        if (sobotIsNull(model.richModel.richmoreurl)) {
            height = height + 5;
            
        }
    }else{
        [self sugesstionLabel].hidden = YES;
        
        rw = size.width;
    }
    
#pragma mark -- 展开
    //设置线条
    if (!sobotIsNull(model.richModel.richmoreurl)) {
        // 设置最大宽度
        rw = maxWidth;
        // 清理内部控件
        [[self lookMoreLabel].subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
//         添加线条
        _lineView  = [[UIView alloc]init];
        lineF = CGRectMake(GetCellItemX(self.isRight) + 12, height + 25, rw , 1);
        [_lineView setFrame:lineF];
        _lineView.backgroundColor = [ZCUITools zcgetLineRichColor];
        [self.contentView addSubview:_lineView];
        _lineView.hidden = NO;
        height = height + 26;
        
        if (self.isRight) {
            [self.lookMoreLabel setTextColor:[ZCUITools zcgetRightChatTextColor]];
            [self.lookMoreLabel setLinkColor:[ZCUITools zcgetChatRightlinkColor]];
        }else{
            [self.lookMoreLabel setLinkColor:[ZCUITools zcgetChatLeftLinkColor]];
            [self.lookMoreLabel setTextColor:[ZCUITools zcgetLeftChatTextColor]];
        }
        self.lookMoreLabel.hidden = NO;
        NSString *linkText = ZCSTLocalString(@"查看详情");
        
        if([model.richModel.richmoreurl isEqual:@"zc_refresh_newdata"]){
            
            
            linkText = ZCSTLocalString(@"换一组");
            UIImageView *img = [[UIImageView alloc] initWithImage:[ZCUITools zcuiGetBundleImage:@"zcicon_refreshbar_new"] ];
            
            [img setFrame:CGRectMake((maxWidth + 30)/2 - 38, 10, 10, 10)];
            [[self lookMoreLabel] addSubview:img];
            [[self lookMoreLabel] setTextAlignment:NSTextAlignmentCenter];
            [[self lookMoreLabel] setFont:ZCUIFontBold12];
//            self.
        }else{
            
            [[self lookMoreLabel] setTextAlignment:NSTextAlignmentCenter];
            [[self lookMoreLabel] setFont:ZCUIFontBold12];

        }
        self.lookMoreLabel.text = linkText;
        // 一定要在设置text文本之后设置
        [[self lookMoreLabel] addLinkToURL:[NSURL URLWithString:model.richModel.richmoreurl] withRange:NSMakeRange(0, linkText.length)];
//        CGSize size = [[self lookMoreLabel]preferredSizeWithMaxWidth:maxWidth];
        moreF = CGRectMake(12, CGRectGetMaxY(_lineView.frame) + 5, maxWidth + 30, 30);
        
        [[self lookMoreLabel] setFrame:moreF];
//        [self lookMoreLabel].backgroundColor = [UIColor redColor];
        height = height  + 30;
    }
    
    CGFloat msgX = 0;
    //    2.8.0 文字为一行或者两行的特殊判断
    BOOL msgTextisOneOrTwoLine = NO;
    
//    NSLog(@".....%f",height);

    // 如果显示图片，文本最多显示3行
    if(model.richModel.msgType>0 && !sobotIsNull(model.richModel.richpricurl)){
        rw = maxWidth;
    }
    
    // 0,自己，1机器人，2客服
    if(self.isRight){
        float x = 12;
        int rx = self.viewWidth- rw  - x*2 - 15 - 5;
        msgX = rx + 15;
        if (!sobotIsNull(model.richModel.richpricurl)) {
            [self.ivBgView setFrame:CGRectMake(rx , bgY, rw + 30 , height)];
        }else{
            [self.ivBgView setFrame:CGRectMake(rx , bgY, rw + 30 , height)];
        }
    }else{
        float x = 12;
        msgX = x + 15;
        //        2.8.0
        // 有顶 踩
        float lineHeight = 0; // 一行高度
        if (model.senderType == 1 && (model.commentType == 1 || model.commentType == 2||model.commentType == 3|| model.commentType == 4)) {
            
            if (size.height <= 25) {
                msgTextisOneOrTwoLine = YES;
                lineHeight = 25;
                height = height + lineHeight;
            }
            else if (size.height <= 42) {
                msgTextisOneOrTwoLine = YES;
            }
            
        }
        
        if (!sobotIsNull(model.richModel.richpricurl)) {
            [self.ivBgView setFrame:CGRectMake(x, bgY, rw+30  , height)];
        }else{
            
            [self.ivBgView setFrame:CGRectMake(x, bgY, rw+30 , height)];
        }
        
        if (size.height == 0) {
            [self.ivBgView setFrame:CGRectMake(0, 0, 0, 0)];
            self.ivBgView.hidden = YES;
        }else{
            self.ivBgView.hidden = NO;

        }
        
        
    }
    
    imgF.origin.y = imgF.origin.y + bgY;
    msgF.origin.y = msgF.origin.y + bgY;
    sugestionF.origin.y = sugestionF.origin.y + bgY;
    lineF.origin.y = lineF.origin.y + bgY;
    moreF.origin.y = moreF.origin.y + bgY;
    
    
    msgF.origin.x = msgX;
    sugestionF.origin.x = msgX;
    imgF.origin.x = msgX;
    lineF.origin.x = msgX;
    

    
    self.middleImageView.frame = imgF;
    //    NSLog(@"msgF..%f,%f,%f,%f",msgF.origin.x,msgF.origin.y,msgF.size.width,msgF.size.height);
    [[self emojiLabel] setFrame:msgF];
    [[self sugesstionLabel] setFrame:sugestionF];
//    _lineView.frame = lineF;
//    self.lookMoreLabel.frame = moreF;
    
    CGFloat sh = [self setSendStatus:self.ivBgView.frame];
    
    //    NSLog(@"msgF..%f,%f,%f,%f",self.ivBgView.frame.origin.x,self.ivBgView.frame.origin.y,self.ivBgView.frame.size.width,self.ivBgView.frame.size.height);
    
    //    NSLog(@"self.contentView... %f",ScreenWidth);
    [self isAddBottomBgView:self.ivBgView.frame msgIsOneLine:msgTextisOneOrTwoLine];
    
    
    // 设置尖角
    [self.ivLayerView setFrame:self.ivBgView.frame];
    CALayer *layer              = self.ivLayerView.layer;
    layer.frame                 = (CGRect){{0,0},self.ivLayerView.layer.frame.size};
    self.ivBgView.layer.mask = layer;
    [self.ivBgView setNeedsDisplay];
    
    [self setFrame:CGRectMake(0, 0, self.viewWidth, height+bgY + sh + 10)];
    return height+bgY + 10 + sh;
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
            int index = [[url stringByReplacingOccurrencesOfString:@"sobot://" withString:@""] intValue];
            
            if(index > 0 && self.tempModel.richModel.suggestionArr.count>=index){
                if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]){
                    [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeItemChecked obj:[NSString stringWithFormat:@"%d",index-1]];
                }
                return;
            }
            
            if(index > 0 && self.tempModel.richModel.multiModel.interfaceRetList.count>=index){
                
                // 单独处理对象
                NSDictionary * dict = @{@"requestText": self.tempModel.richModel.multiModel.interfaceRetList[index-1][@"title"],
                                        @"question":[self getQuestion:self.tempModel.richModel.multiModel.interfaceRetList[index-1]],
                                        @"questionFlag":@"2",
                                        @"title":self.tempModel.richModel.multiModel.interfaceRetList[index-1][@"title"],
                                        @"ishotguide":@"0"
                                        };
                if ([self getZCLibConfig].isArtificial) {
                    dict = @{@"title":self.tempModel.richModel.multiModel.interfaceRetList[index-1][@"title"],@"ishotguide":@"0"};
                }
                
                if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]){
                    [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeItemGuide obj: dict];
                }
            }
            
            
        }else if ([url hasPrefix:@"robot:"]){
            // 处理 机器人回复的 技能组点选事件
            
//          3.8.0 如果当前 已转人工 ， 不可点击
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



// 点击查看大图
-(void) imgTouchUpInside:(UITapGestureRecognizer *)recognizer{
    UIImageView *picTempView=(UIImageView*)recognizer.view;
    
    
    CGRect f = [picTempView convertRect:picTempView.bounds toView:nil];
    
    UIImageView *bgView = [[UIImageView alloc] init];
    [bgView setImage:self.ivLayerView.image];
    // 设置尖角
    [bgView setFrame:f];
    CALayer *layer              = bgView.layer;
    layer.frame                 = (CGRect){{0,0},bgView.layer.frame.size};
        
    SobotImageView *newPicView = [[SobotImageView alloc] init];
    newPicView.image = picTempView.image;
    newPicView.frame = f;
    newPicView.layer.masksToBounds = NO;
//    newPicView.layer.cornerRadius = 15;
    
    newPicView.layer.mask = layer;
    CALayer *calayer = newPicView.layer.mask;
    [newPicView.layer.mask removeFromSuperlayer];
    
    __weak ZCRichTextChatCell *weakSelf = self;
    SobotXHImageViewer *xh=[[SobotXHImageViewer alloc] initWithImageViewerWillDismissWithSelectedViewBlock:^(SobotXHImageViewer *imageViewer, UIImageView *selectedView) {
        
    } didDismissWithSelectedViewBlock:^(SobotXHImageViewer *imageViewer, UIImageView *selectedView) {
        selectedView.layer.mask = calayer;
        [selectedView setNeedsDisplay];
        [selectedView removeFromSuperview];
        
        if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]){
            [weakSelf.delegate cellItemClick:weakSelf.tempModel type:ZCChatCellClickTypeTouchImageNO obj:self];
            //                        [self.delegate touchLagerImageView:xh with:NO];
        }
    } didChangeToImageViewBlock:^(SobotXHImageViewer *imageViewer, UIImageView *selectedView) {
        
    }];
    
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    [photos addObject:picTempView];
    
    xh.delegate = self;
    xh.disableTouchDismiss = NO;
    _imageViewer = xh;
    
    [xh showWithImageViews:photos selectedView:picTempView];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]){
        //        [self.delegate touchLagerImageView:xh with:YES];
        [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeTouchImageYES obj:xh];
    }
    
    // 添加长按手势，保存图片
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressAction:)];
    [xh addGestureRecognizer:longPress];
    
}

#pragma mark -- 保存图片到相册
- (void)longPressAction:(UILongPressGestureRecognizer*)longPress{
    //    NSLog(@"长按保存");
    if (longPress.state != UIGestureRecognizerStateBegan) {
        return;
    }
    NSString *str = [[ZCToolsCore getToolsCore] coderURLStrDetectorWith:_middleImageView.image];
    if (str) {
        ZCActionSheet *mysheet = [[ZCActionSheet alloc] initWithDelegate:self selectedColor:nil CancelTitle:ZCSTLocalString(@"取消") OtherTitles:ZCSTLocalString(@"保存图片"),ZCSTLocalString(@"识别二维码"), nil];
        mysheet.tag = 100;
        _coderURLStr = str;
        [mysheet show];
    }else{
        ZCActionSheet *mysheet = [[ZCActionSheet alloc] initWithDelegate:self selectedColor:nil CancelTitle:ZCSTLocalString(@"取消") OtherTitles:ZCSTLocalString(@"保存图片"), nil];
        [mysheet show];
    }
    
}

- (void)actionSheet:(ZCActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        // 保存图片到相册
        UIImageWriteToSavedPhotosAlbum(_middleImageView.image, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
    }
    else if (buttonIndex == 2){
        [_imageViewer dismissWithAnimate];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemLinkClick:type:obj:)]){
                [self.delegate cellItemLinkClick:@"" type:ZCChatCellClickTypeOpenURL obj:_coderURLStr];
            }
        });
    }
}

- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString *msg = nil;
    if (error != NULL) {
        //        msg = @"保存失败";
    }else{
        msg = ZCSTLocalString(@"已保存到系统相册");
        [[ZCUIToastTools shareToast] showToast:msg duration:1.0f view:_middleImageView position:ZCToastPositionCenter Image:[ZCUITools zcuiGetBundleImage:@"zcicon_successful"]];
    }
    
}


-(void)resetCellView{
    [super resetCellView];
    
    _lblTextMsg.text = @"";
    //    _sugguestLabel = nil;
    [_middleImageView setHidden:YES];
    _lineView.hidden = YES;
    [_lookMoreLabel setHidden:YES];
    
}



+(CGFloat)getCellHeight:(ZCLibMessage *)model time:(NSString *)showTime viewWith:(CGFloat )viewWidth{
    
    CGFloat cellheith = [super getCellHeight:model time:showTime viewWith:viewWidth];
    CGFloat maxWidth = viewWidth - 100;
    
    // 有顶 踩
//    if (model.senderType == 1 && (model.commentType == 1 || model.commentType == 2||model.commentType == 3|| model.commentType == 4)) {
//        maxWidth=viewWidth - 90 - 32 - 50;
//
//    }
    
    
    static ZCMLEmojiLabel *tempLabel = nil;
    if (!tempLabel) {
        tempLabel = [[ZCMLEmojiLabel alloc] initWithFrame:CGRectZero];
        tempLabel.numberOfLines = 0;
        tempLabel.font = [ZCUITools zcgetKitChatFont];
        tempLabel.backgroundColor = [UIColor clearColor];
        tempLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        tempLabel.textColor = [UIColor whiteColor];
        tempLabel.isNeedAtAndPoundSign = YES;
        tempLabel.disableEmoji = NO;
        tempLabel.lineSpacing = 3.0f;
        tempLabel.verticalAlignment = ZCTTTAttributedLabelVerticalAlignmentCenter;
        //        tempLabel.textInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    }
    
    tempLabel.font = [ZCUITools zcgetKitChatFont];

    if(model.displayMsgAttr!=nil){
        [ZCChatBaseCell setDisplayAttributedString:model.displayMsgAttr label:tempLabel  model:model guide:NO];
        
    }else{
        
        [ZCHtmlCore filterHtml:[model getModelDisplayText] result:^(NSString * _Nonnull text1, NSMutableArray * _Nonnull arr, NSMutableArray * _Nonnull links) {
            if (text1 != nil && text1.length > 0) {
                UIFont *font = [ZCUITools zcgetKitChatFont];
                if(model.isRobotGuide){
                    font = ZCUIFontBold14;
                }
                tempLabel.attributedText =    [ZCHtmlFilter setHtml:text1 attrs:arr view:tempLabel textColor:[ZCUITools zcgetLeftChatTextColor] textFont:font linkColor:[ZCUITools zcgetChatLeftLinkColor]];
            }else{
                tempLabel.attributedText =   [[NSAttributedString alloc] initWithString:@""];
            }
        }];
    }
    
    
//    cellheith = cellheith + 12;
    
    // 文本高度
    CGSize msgSize = [tempLabel preferredSizeWithMaxWidth:maxWidth];
    //    NSLog(@"size0000112...%f %f %f",msgSize.width,msgSize.height,maxWidth);
    
    // 如果图片不为空 先放置图片
    if (model.richModel.msgType >0 && !sobotIsNull(model.richModel.richpricurl)) {

        cellheith = cellheith + MidImageHeight + 10 + Spaceheight;

        // 如果显示图片，文本最多显示3行
        if(!sobotIsNull(model.richModel.richpricurl)){
            // 有标题的需要显示4行，不带标题最多显示3行
            if (sobotConvertToString(model.richModel.question).length > 0) {
                if (msgSize.height > 110) {
                    msgSize.height = 110;
                }
            }else{
                if(msgSize.height>70){
                    msgSize.height = 70;
                }
            }
        }
    }else{
        cellheith = cellheith + 10;
    }
    
    cellheith = cellheith + msgSize.height + 10 + Spaceheight;
    if(sobotConvertToString([model getModelDisplaySugestionText]).length > 0){
        tempLabel.text = nil;
        
        if(model.displaySugestionattr!=nil){
            
            UIColor *textColor = [ZCUITools zcgetLeftChatTextColor];
            UIColor *linkColor = [ZCUITools zcgetChatLeftLinkColor];
            if([ZCChatBaseCell isRightChat:model]){
                textColor = [ZCUITools zcgetRightChatTextColor];
                linkColor = [ZCUITools zcgetChatRightlinkColor];
            }
//            NSMutableAttributedString* attributedString = [model.displaySugestionattr mutableCopy];
            [ZCChatBaseCell setDisplayAttributedString:model.displaySugestionattr label:tempLabel  model:model guide:YES];
            
        }else{
            [ZCHtmlCore filterHtml:[model getModelDisplaySugestionText] result:^(NSString * _Nonnull text1, NSMutableArray * _Nonnull arr, NSMutableArray * _Nonnull links) {
                if (text1 != nil && text1.length > 0) {
                    tempLabel.attributedText =    [ZCHtmlFilter setGuideHtml:text1 attrs:arr view:tempLabel textColor:[ZCUITools zcgetLeftChatTextColor] textFont:[ZCUITools zcgetKitChatFont] linkColor:[ZCUITools zcgetChatLeftLinkColor]];
                }else{
                    tempLabel.attributedText =   [[NSAttributedString alloc] initWithString:@""];
                }
            }];
        }
        // 文本高度
        CGSize msgSize1 = [tempLabel preferredSizeWithMaxWidth:maxWidth];
        
        if (model.richModel.msgType == 15 || model.richModel.msgType == 3) {
            msgSize1.height = 0;

            cellheith = cellheith - 10;

        }else{
            // 添加引导行间距
            CGFloat xlineSpace = [ZCUITools zcgetKitChatFont].lineHeight;
            
            cellheith = cellheith + msgSize1.height + 10  + xlineSpace;

        }
        
        //        没有 换一组
        if (sobotIsNull(model.richModel.richmoreurl)) {
            cellheith = cellheith + 5;
        }
    }
    
    
    // 多轮会话的富文本，消息解析错误，需要转换一次
    if(model.richModel.msgType == 15 && model.richModel.multiModel.templateIdType == 3){
        NSMutableDictionary * detailDict = model.richModel.multiModel.interfaceRetList.firstObject; // 多个
        model.richModel.richpricurl = sobotConvertToString(detailDict[@"thumbnail"]);
        model.richModel.richmoreurl = sobotConvertToString(detailDict[@"anchor"]);
    }
    
    
    // 阅读全文
    if(!sobotIsNull(model.richModel.richmoreurl)){
        
        // 线条的高度
        cellheith = cellheith + 26;
        
        tempLabel.font = ZCUIFontBold14;
        tempLabel.text = ZCSTLocalString(@"查看详情");
//        CGSize sugguestSize = [tempLabel preferredSizeWithMaxWidth:maxWidth];
        
        if([model.richModel.richmoreurl isEqual:@"zc_refresh_newdata"]){
            cellheith = cellheith + 45 - 10;
        }else{
            cellheith = cellheith + 45;

        }
        
    }
    
//    cellheith=cellheith ;
    
    //////////////////////////////////////
    // 可能添加40
    cellheith = cellheith +  [ZCChatBaseCell getStatusHeight:model];;
    //////////////////////////////////////
    //        2.8.0
    // 有顶 踩
    float lineHeight = 0; // 一行高度
    if (model.senderType == 1 && (model.commentType == 1 || model.commentType == 2||model.commentType == 3|| model.commentType == 4)) {
        
        if (msgSize.height <= 25) {
            lineHeight = 20;
            cellheith = cellheith + lineHeight;
        }
    }
    
    return cellheith + 10;
}



-(NSString *)getQuestion:(NSDictionary *)model{
    if(model){
        NSMutableDictionary *recDict = [NSMutableDictionary dictionaryWithDictionary:model];
        [recDict removeObjectForKey:@"title"];
        return [ZCLocalStore DataTOjsonString:recDict];
    }
    return @"";
}

-(ZCLibConfig *) getZCLibConfig{
    //    return [ZCIMChat getZCIMChat].config;
    return [[ZCPlatformTools sharedInstance] getPlatformInfo].config;
}

@end
