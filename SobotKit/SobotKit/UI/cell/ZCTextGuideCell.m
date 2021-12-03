//
//  ZCTestGuideCell.m
//  SobotKit
//
//  Created by lizhihui on 2018/6/28.
//  Copyright © 2018年 zhichi. All rights reserved.
//

#import "ZCTextGuideCell.h"
#import "SobotXHImageViewer.h"
#import "SobotImageView.h"
#import "ZCLibGlobalDefine.h"
#import "ZCActionSheet.h"
#import "ZCUIToastTools.h"
#import "ZCUIColorsDefine.h"
#import "ZCPlatformTools.h"
#import "ZCIMChat.h"
#import "ZCLocalStore.h"
#define MidImageHeight 110

#import "ZCHtmlCore.h"
#import "ZCHtmlFilter.h"
#import "ZCToolsCore.h"

@interface ZCTextGuideCell()<ZCMLEmojiLabelDelegate,SobotXHImageViewerDelegate,ZCActionSheetDelegate>{
    NSString    *callURL;
    ZCMLEmojiLabel *_lblEmojiQuestion;// 标题
    ZCMLEmojiLabel *_lblTextMsg;
    SobotImageView *_middleImageView; // 图片
    ZCMLEmojiLabel *_sugguestLabel;  // 引导建议
    ZCMLEmojiLabel *_lookMoreLabel; // 展开
    UIView       * _lineView; // 线条
    ZCMLEmojiLabel * _lblAnswerType;// 多轮会话 15239 1523 1524 时使用
    
    UILabel * _msgTextLab;// 多轮会话处理高亮标签
    NSString *_coderURLStr;
    SobotXHImageViewer *_imageViewer;
}

@end

@implementation ZCTextGuideCell

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

- (UILabel *)msgTextLab // 中间的消息体
{
    if (!_msgTextLab) {
        _msgTextLab = [UILabel new];
        _msgTextLab.numberOfLines = 0;
        _msgTextLab.font = [ZCUITools zcgetKitChatFont];
        //        _lblTextMsg.delegate = self;
        _msgTextLab.lineBreakMode = NSLineBreakByTruncatingTail;
        _msgTextLab.textColor = [UIColor whiteColor];
        _msgTextLab.backgroundColor = [UIColor clearColor];
        _msgTextLab.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_msgTextLab];
    }
    return _msgTextLab;
}

- (ZCMLEmojiLabel *)lblAnswerType // 中间的消息体
{
    if (!_lblAnswerType) {
        _lblAnswerType = [[ZCMLEmojiLabel alloc] initWithFrame:CGRectZero];
        _lblAnswerType.numberOfLines = 0;
        _lblAnswerType.font = [ZCUITools zcgetKitChatFont];
        _lblAnswerType.delegate = self;
        _lblAnswerType.lineBreakMode = NSLineBreakByTruncatingTail;
        _lblAnswerType.textColor = [UIColor whiteColor];
        _lblAnswerType.backgroundColor = [UIColor clearColor];
        _lblAnswerType.isNeedAtAndPoundSign = NO;
        _lblAnswerType.disableEmoji = NO;
        _lblAnswerType.lineSpacing = 3.0f;
        _lblAnswerType.verticalAlignment = ZCTTTAttributedLabelVerticalAlignmentCenter;
        [self.contentView addSubview:_lblAnswerType];
    }
    return _lblAnswerType;
}

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

-(ZCMLEmojiLabel *)lblEmojiQuestion{
    if(!_lblEmojiQuestion){
        _lblEmojiQuestion = [[ZCMLEmojiLabel alloc] initWithFrame:CGRectZero];
        _lblEmojiQuestion.numberOfLines = 0;
        
        UIFontDescriptor *ctfFont = [ZCUITools zcgetKitChatFont].fontDescriptor;
        NSNumber *fontString = [ctfFont objectForKey:@"NSFontSizeAttribute"];
        _lblEmojiQuestion.font = [UIFont boldSystemFontOfSize:[fontString floatValue]];
        
        _lblEmojiQuestion.delegate = self;
        _lblEmojiQuestion.lineBreakMode = NSLineBreakByTruncatingTail;
        _lblEmojiQuestion.textColor = [UIColor whiteColor];
        _lblEmojiQuestion.backgroundColor = [UIColor clearColor];
        
        
        _lblEmojiQuestion.isNeedAtAndPoundSign = NO;
        _lblEmojiQuestion.disableEmoji = NO;
        
        _lblEmojiQuestion.lineSpacing = 3.0f;
        
        _lblEmojiQuestion.verticalAlignment = ZCTTTAttributedLabelVerticalAlignmentCenter;
        [self.contentView addSubview:_lblEmojiQuestion];
        
    }
    return _lblEmojiQuestion;
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

- (ZCMLEmojiLabel *)sugguestLabel
{
    if (!_sugguestLabel) {
        _sugguestLabel = [[ZCMLEmojiLabel alloc] initWithFrame:CGRectZero];
        _sugguestLabel.numberOfLines = 0;
        _sugguestLabel.font = [ZCUITools zcgetKitChatFont];
        _sugguestLabel.delegate = self;
        _sugguestLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _sugguestLabel.textColor = [UIColor whiteColor];
        _sugguestLabel.backgroundColor = [UIColor clearColor];
        //        _sugguestLabel.textInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        _sugguestLabel.isGuideCell = YES;
        _sugguestLabel.isNeedAtAndPoundSign = NO;
        _sugguestLabel.disableEmoji = NO;
        _sugguestLabel.lineSpacing = 3.0f;
        _sugguestLabel.verticalAlignment = ZCTTTAttributedLabelVerticalAlignmentCenter;
        [self.contentView addSubview:_sugguestLabel];
    }
    return _sugguestLabel;
}


- (ZCMLEmojiLabel *)lookMoreLabel
{
    if (!_lookMoreLabel) {
        _lookMoreLabel = [[ZCMLEmojiLabel alloc] initWithFrame:CGRectZero];
        _lookMoreLabel.numberOfLines = 0;
        _lookMoreLabel.font = [ZCUITools zcgetKitChatFont];
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
    UIMenuController *menuController = [UIMenuController sharedMenuController];
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
    
    [self emojiLabel].text = @"";
    _lblAnswerType.text  = @"";
    CGFloat AW = 0;
    CGFloat rw = 0;
    
    CGRect awF = CGRectZero;
    CGRect questionF = CGRectZero;
    CGRect msgF = CGRectZero;
    CGRect imgF = CGRectZero;
    CGRect sugF = CGRectZero;
    CGRect linF = CGRectZero;
    CGRect moreF = CGRectZero;
    
    if ([ZCChatBaseCell getStatusHeight:model] >0) {
        // 显示顶踩 固定最大宽度
        rw = self.maxWidth;
    }
    
    for (UIView *v in self.ivBgView.subviews) {
        [v removeFromSuperview];
    }
    if(_sugguestLabel!=nil){
        _sugguestLabel.hidden = YES;
    }
    //    if (_lblAnswerType != nil) {
    //        _lblAnswerType.hidden = YES;
    //    }
    
    if (model.richModel.msgType == 0 || model.richModel.msgType == 5) {
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(doLongPress:)];
        
        [self.emojiLabel addGestureRecognizer:longPress];
        
        // 添加复制框消失的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willHideEditMenu:) name:UIMenuControllerDidHideMenuNotification object:nil];
        
    }
    CGFloat height = 0;
#pragma mark -- 提示语 多轮会话使用
    if (model.richModel.answerStrip.length >0) {
        //        [self lblAnswerType].hidden = NO;
        
        //        [self lblAnswerType].textColor = [ZCUITools zcgetLeftChatTextColor];
        // 必须在赋值之前设置
        if(self.isRight){
            [[self lblAnswerType] setTextColor:[ZCUITools zcgetRightChatTextColor]];
            [[self lblAnswerType] setLinkColor:[ZCUITools zcgetChatRightlinkColor]];
        }else{
            [[self lblAnswerType] setTextColor:[ZCUITools zcgetLeftChatTextColor]];
            [[self lblAnswerType] setLinkColor:[ZCUITools zcgetChatLeftLinkColor]];
            
        }
        
        [self lblAnswerType].text =  zcLibConvertToString(model.richModel.answerStrip);
        CGSize size = [[self lblAnswerType] preferredSizeWithMaxWidth:self.maxWidth];
        
        awF = CGRectMake(GetCellItemX(self.isRight), height, size.width, size.height);
        [[self lblAnswerType] setFrame:awF];
        
        AW = size.width;
        height = height + size.height + 10 + Spaceheight;
        
    }
    
#pragma mark  -- 图片
    
    // 处理图片  当前的图片高度固定110
    if(model.richModel.msgType>0 && !zcLibIs_null(model.richModel.richpricurl)){
        if(rw < ImageHeight){
            rw = ImageHeight;
        }
        [[self middleImageView] loadWithURL:[NSURL URLWithString:zcUrlEncodedString(model.richModel.richpricurl)] placeholer:nil showActivityIndicatorView:YES];
        [self middleImageView].hidden=NO;
        
        [self middleImageView].userInteractionEnabled=YES;
        UITapGestureRecognizer *labelTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imgTouchUpInside:)];
        [[self middleImageView] addGestureRecognizer:labelTapGestureRecognizer];
        imgF = CGRectMake(GetCellItemX(self.isRight), height, rw, MidImageHeight);
        [self.middleImageView setFrame:imgF];
        height = height + MidImageHeight + 10 + Spaceheight;
        
    }
    
    
#pragma mark 标题
    NSString *question = zcLibConvertToString(model.richModel.question);
    
    if(![@"" isEqual:question]){
        [self lblEmojiQuestion].text = @"";
    }
    
    // 必须在赋值之前设置
    if(self.isRight){
        [self.emojiLabel setTextColor:[ZCUITools zcgetRightChatTextColor]];
        [self.emojiLabel setLinkColor:[ZCUITools zcgetChatRightlinkColor]];
        
        if(![@"" isEqual:question]){
            [self.lblEmojiQuestion setTextColor:[ZCUITools zcgetRightChatTextColor]];
            [self.lblEmojiQuestion setLinkColor:[ZCUITools zcgetChatRightlinkColor]];
        }
    }else{
        [self.emojiLabel setTextColor:[ZCUITools zcgetLeftChatTextColor]];
        [self.emojiLabel setLinkColor:[ZCUITools zcgetChatLeftLinkColor]];
        
        if(![@"" isEqual:question]){
            [self.lblEmojiQuestion setTextColor:[ZCUITools zcgetLeftChatTextColor]];
            [self.lblEmojiQuestion setLinkColor:[ZCUITools zcgetChatLeftLinkColor]];
        }
    }
    
    //    CGFloat height=12;
    //判断显示标题
    if(![@"" isEqual:question]){
        self.lblEmojiQuestion.text  = question;
        CGSize size = [self.lblEmojiQuestion preferredSizeWithMaxWidth:self.maxWidth];
        
        questionF = CGRectMake(GetCellItemX(self.isRight), height, size.width, size.height);
        [[self lblEmojiQuestion] setFrame:questionF];
        
        rw = size.width;
        height = height + size.height + 10 + Spaceheight;
        
        
    }
    
#pragma mark -- 中间的文本内容详情，如果图片是显示的，最多显示3行
    NSString *text=model.richModel.msg;
    // 处理换行
    text = [text stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
    text = [text stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
    text = [text stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
    text = [text stringByReplacingOccurrencesOfString:@"<BR/>" withString:@"\n"];
    text = [text stringByReplacingOccurrencesOfString:@"<BR />" withString:@"\n"];
    text = [text stringByReplacingOccurrencesOfString:@"<p " withString:@"\n<p "];
    text = [text stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
    
    text = [text stringByReplacingOccurrencesOfString:@"<font color='red'>" withString:@"<a href=\"sobot://color\">"];
    text = [text stringByReplacingOccurrencesOfString:@"</font>" withString:@"</a>"];
    while ([text hasPrefix:@"\n"]) {
        text=[text substringWithRange:NSMakeRange(1, text.length-1)];
    }
    BOOL isNotFound = NO;
    if ([text rangeOfString:@"<a href=\"sobot://color\">"].location != NSNotFound) {
        isNotFound = YES;
    }
    
    [ZCHtmlCore filterHtml:text result:^(NSString * _Nonnull text1, NSMutableArray * _Nonnull arr, NSMutableArray * _Nonnull links) {
        if (self.isRight) {
            UIColor *linkColor = [ZCUITools zcgetChatRightlinkColor];
            if (isNotFound) {
                linkColor = [UIColor redColor];
            }
            if (text1 != nil && text1.length > 0) {
                _lblTextMsg.attributedText =   [ZCHtmlFilter setHtml:text1 attrs:arr view: _lblTextMsg textColor:[ZCUITools zcgetRightChatTextColor] textFont:[ZCUITools zcgetKitChatFont] linkColor:linkColor];
            }else{
                _lblTextMsg.attributedText =   [[NSAttributedString alloc] initWithString:@""];
            }
            
        }else{
            UIColor *linkColor = [ZCUITools zcgetChatLeftLinkColor];
            if (isNotFound) {
                linkColor = [UIColor redColor];
            }
            if (text1 != nil && text1.length > 0) {
                _lblTextMsg.attributedText =    [ZCHtmlFilter setHtml:text1 attrs:arr view: _lblTextMsg textColor:[ZCUITools zcgetLeftChatTextColor] textFont:[ZCUITools zcgetKitChatFont] linkColor:linkColor];
            }else{
                _lblTextMsg.attributedText =   [[NSAttributedString alloc] initWithString:@""];
            }
            
        }
    }];
    
    //    NSMutableDictionary *dict = [self.emojiLabel getTextADict:text];
    //    if(dict){
    //        text = dict[@"text"];
    //    }
    //
    //    _lblTextMsg.text = text;
    //    if(dict){
    //        NSArray *arr = dict[@"arr"];
    //        //    [_emojiLabel setText:tempText];
    //        for (NSDictionary *item in arr) {
    //            NSString *text = item[@"htmlText"];
    //            int loc = [item[@"realFromIndex"] intValue];
    //            if (isNotFound) {
    //                [_lblTextMsg setLinkColor:[UIColor redColor]];
    //            }
    //            // 一定要在设置text文本之后设置
    //            [_lblTextMsg addLinkToURL:[NSURL URLWithString:item[@"url"]] withRange:NSMakeRange(loc, text.length)];
    //        }
    //    }
    
    CGSize size = [self.emojiLabel preferredSizeWithMaxWidth:self.maxWidth];
    
    if(rw < size.width){
        rw = size.width;
    }
    
    // 如果显示图片，文本最多显示3行
    if(model.richModel.msgType>0 && !zcLibIs_null(model.richModel.richpricurl)){
        // 最多显示三行
        if(size.height>70){
            size.height = 70;
        }
    }
    
    
    msgF = CGRectMake(GetCellItemX(self.isRight), height, size.width, size.height);
    [[self msgTextLab] setFrame:msgF];
    
    height = height + size.height +10 + Spaceheight;
    
    
    
    NSString *sugguestText=@"";
    
    // 添加stripe
    if(![@"" isEqual:zcLibConvertToString(model.richModel.stripe)]){
        sugguestText = [sugguestText stringByAppendingString:model.richModel.stripe];
    }
    
#pragma mark -- 添加引导建议
    // 添加建议
    if(model.richModel.multiModel.interfaceRetList!=nil && model.richModel.multiModel.interfaceRetList.count>0 && model.isHistory){
        int i=1;
        for (NSDictionary *item in model.richModel.multiModel.interfaceRetList) {
            NSString *linkString = [NSString stringWithFormat:@"• %@",item[@"title"]];
            
            if([sugguestText hasSuffix:@"\n"]){
                sugguestText=[NSString stringWithFormat:@"%@%@",sugguestText,linkString];
            }else{
                sugguestText=[NSString stringWithFormat:@"%@\n%@",sugguestText,linkString];
            }
            i=i+1;
        }
    }else if(model.richModel.multiModel.interfaceRetList!=nil && model.richModel.multiModel.interfaceRetList.count>0){
        int i=1;
        for (NSDictionary *item in model.richModel.multiModel.interfaceRetList) {
            NSString *linkString = [NSString stringWithFormat:@"<a href=\"sobot://%d\">• %@</a>",i,item[@"title"]];
            if([sugguestText hasSuffix:@"\n"]){
                sugguestText=[NSString stringWithFormat:@"%@%@",sugguestText,linkString];
            }else{
                sugguestText=[NSString stringWithFormat:@"%@\n%@",sugguestText,linkString];
            }
            i=i+1;
        }
    }
    
    // 去掉尾部换行
    while ([sugguestText hasPrefix:@"\n"]) {
        sugguestText=[sugguestText substringWithRange:NSMakeRange(1, sugguestText.length-1)];
    }
    
    
    CGSize sugguestSize=CGSizeZero;
    if(![@"" isEqual:sugguestText]){
        self.sugguestLabel.text = @"";
        // 必须在赋值之前设置
        //        if(self.isRight){
        //            [self.sugguestLabel setTextColor:[ZCUITools zcgetRightChatTextColor]];
        //            [self.sugguestLabel setLinkColor:[ZCUITools zcgetChatRightlinkColor]];
        //        }else{
        //            [self.sugguestLabel setTextColor:[ZCUITools zcgetLeftChatTextColor]];
        //            [self.sugguestLabel setLinkColor:[ZCUITools zcgetChatLeftLinkColor]];
        //        }
        _sugguestLabel.hidden  = NO;
        
        
        [ZCHtmlCore filterHtml:text result:^(NSString * _Nonnull text1, NSMutableArray * _Nonnull arr, NSMutableArray * _Nonnull links) {
            if (self.isRight) {
                if (text1 !=nil && text1.length > 0) {
                    self.sugguestLabel.attributedText =   [ZCHtmlFilter setHtml:text1 attrs:arr view:self.sugguestLabel textColor:[ZCUITools zcgetRightChatTextColor] textFont:[ZCUITools zcgetKitChatFont] linkColor:[ZCUITools zcgetChatRightlinkColor]];
                }else{
                    self.sugguestLabel.attributedText =  [[NSAttributedString alloc] initWithString:@""];
                }
                
            }else{
                if (text1 != nil && text1.length > 0) {
                    self.sugguestLabel.attributedText =    [ZCHtmlFilter setHtml:text1 attrs:arr view:self.sugguestLabel textColor:[ZCUITools zcgetLeftChatTextColor] textFont:[ZCUITools zcgetKitChatFont] linkColor:[ZCUITools zcgetChatLeftLinkColor]];
                }else{
                    self.sugguestLabel.attributedText =    [[NSAttributedString alloc] initWithString:@""];
                }
                
            }
        }];
        
        
        //        NSMutableDictionary *sugguestDict = [[self sugguestLabel] getTextADict:sugguestText];
        
        //        [self sugguestLabel].text = sugguestText;
        //
        //        if(sugguestDict){
        //            sugguestText = sugguestDict[@"text"];
        //            [self sugguestLabel].text = sugguestText;
        //
        //            NSArray *sugguestArr = sugguestDict[@"arr"];
        //            //    [_emojiLabel setText:tempText];
        //            for (NSDictionary *item in sugguestArr) {
        //                NSString *text = item[@"htmlText"];
        //                int loc = [item[@"realFromIndex"] intValue];
        //
        //
        //                // 一定要在设置text文本之后设置
        //                [[self sugguestLabel] addLinkToURL:[NSURL URLWithString:[item[@"url"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] withRange:NSMakeRange(loc, text.length)];
        //            }
        //        }
        sugguestSize = [[self sugguestLabel] preferredSizeWithMaxWidth:self.maxWidth];
        
        sugF = CGRectMake(GetCellItemX(self.isRight), height, sugguestSize.width, sugguestSize.height);
        
        [self.sugguestLabel setFrame:sugF];
        height = height + sugguestSize.height + 10 + Spaceheight;
        
        if(sugguestSize.width>rw){
            rw = sugguestSize.width;
            linF.size.width = rw;
            // 重新计算线条的frame
            [_lineView setFrame:linF];
            
            imgF.size.width = rw;
            [self.middleImageView setFrame:imgF];
        }
    }
    
    
    //设置线条
    if (!zcLibIs_null(model.richModel.richmoreurl)) {
        // 添加线条
        _lineView  = [[UIView alloc]init];
        linF = CGRectMake(GetCellItemX(self.isRight), height, rw, 1);
        [_lineView setFrame:linF];
        _lineView.backgroundColor = [ZCUITools zcgetLineRichColor];
        [self.contentView addSubview:_lineView];
        _lineView.hidden = NO;
        height = height + 10 + Spaceheight + 1;
        
        if (self.isRight) {
            [self.lookMoreLabel setTextColor:[ZCUITools zcgetRightChatTextColor]];
            [self.lookMoreLabel setLinkColor:[ZCUITools zcgetChatRightlinkColor]];
        }else{
            [self.lookMoreLabel setLinkColor:[ZCUITools zcgetChatLeftLinkColor]];
            [self.lookMoreLabel setTextColor:[ZCUITools zcgetLeftChatTextColor]];
        }
        self.lookMoreLabel.hidden = NO;
        self.lookMoreLabel.text = ZCSTLocalString(@"查看详情");
        // 一定要在设置text文本之后设置
        [[self lookMoreLabel] addLinkToURL:[NSURL URLWithString:model.richModel.richmoreurl] withRange:NSMakeRange(0, ZCSTLocalString(@"查看详情").length)];
        
        CGSize size = [[self lookMoreLabel]preferredSizeWithMaxWidth:self.maxWidth];
        moreF = CGRectMake(GetCellItemX(self.isRight), height, size.width, size.height);
        [[self lookMoreLabel] setFrame:moreF];
        
        height = height + size.height + 10 + Spaceheight;
        
    }
    
    CGFloat msgX = 0;
    // 0,自己，1机器人，2客服
    if(self.isRight){
        int rx=self.viewWidth-rw-30 -50;
        msgX = rx;
        if (model.richModel.msgType == 0 || model.richModel.msgType == 5 || [@"" isEqual:question] || !(model.richModel.msgType>0 && !zcLibIs_null(model.richModel.richpricurl))) {
            [self.ivBgView setFrame:CGRectMake(rx-8, bgY, rw+28, height + 10)];
        }else{
            [self.ivBgView setFrame:CGRectMake(rx-8, bgY, rw+28, height)];
        }
        
    }else{
        msgX = 78;
        if (model.richModel.msgType == 0 || model.richModel.msgType == 5 || [@"" isEqual:question] || !(model.richModel.msgType>0 && !zcLibIs_null(model.richModel.richpricurl))) {
            [self.ivBgView setFrame:CGRectMake(58, bgY, rw+33, height +10)];
        }else{
            [self.ivBgView setFrame:CGRectMake(58, bgY, rw+33, height)];
        }
        
    }
    
    msgF.origin.x = msgX;
    msgF.origin.y = msgF.origin.y + bgY ;
    
    if (model.richModel.answerStrip.length >0) {
        awF.origin.x = msgX;
        awF.origin.y = awF.origin.y + bgY + 10;
        [[self lblAnswerType] setFrame:awF];
    }
    
    // 如果是不是富文本消息 整个 Y值增加间距
    if (model.richModel.msgType == 0 || model.richModel.msgType == 5 || [@"" isEqual:question] || !(model.richModel.msgType>0 && !zcLibIs_null(model.richModel.richpricurl))) {
        msgF.origin.y += 10;
    }
    [self.emojiLabel setFrame:msgF];
    //    [[self msgTextLab] setFrame:msgF];
    if(questionF.size.height>0){
        questionF.origin.x = msgX;
        questionF.origin.y = questionF.origin.y + bgY;
        [self.lblEmojiQuestion setFrame:questionF];
    }
    
    
    if(sugF.size.height > 0){
        sugF.origin.x = msgX;
        sugF.origin.y = sugF.origin.y + bgY;
        [self.sugguestLabel setFrame:sugF];
    }
    
    if (linF.size.height >0) {
        linF.origin.x = msgX;
        linF.origin.y = linF.origin.y + bgY;
        [_lineView setFrame:linF];
        
    }
    
    // 重新设置展开的frame
    if (moreF.size.height >0) {
        moreF.origin.x = msgX + CGRectGetWidth(_lineView.frame) - CGRectGetWidth(_lookMoreLabel.frame) ;
        moreF.origin.y = moreF.origin.y +bgY;
        [[self lookMoreLabel] setFrame:moreF];
    }
    
    if(imgF.size.height>0){
        imgF.origin.x = msgX;
        imgF.origin.y = imgF.origin.y + bgY;
        if (CGRectGetWidth(_lineView.frame) != 0) {
            imgF.size.width = CGRectGetWidth(_lineView.frame) + 25;
            imgF.origin.x = msgX - 12 ;
        }
        
        [self.middleImageView setFrame:imgF];
    }
    
    
    CGFloat sh = [self setSendStatus:self.ivBgView.frame];
    
    [self isAddBottomBgView:self.ivBgView.frame msgIsOneLine:YES];
    
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
        
        // 用户引导说辞的分类的点击事件 eg:
        if([url hasPrefix:@"sobot:"]){
            
            
            int index = [[url stringByReplacingOccurrencesOfString:@"sobot://" withString:@""] intValue];
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
            int index = [[url stringByReplacingOccurrencesOfString:@"robot://" withString:@""] intValue];
            if(index > 0 && self.tempModel.groupList.count>=index){
                if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]){
                    [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeGroupItemChecked obj:[NSString stringWithFormat:@"%d",index-1]];
                }
            }
        }else{
            if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemLinkClick:type:obj:)]){
                [self.delegate cellItemLinkClick:htmlText type:ZCChatCellClickTypeOpenURL obj:url];
            }
        }
    }
}



-(BOOL)openQQ:(NSString *)qq{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"mqq://im/chat?chat_type=wpa&uin=%@&version=1&src_type=web",qq]];
    if([[UIApplication sharedApplication] canOpenURL:url]){
        [[UIApplication sharedApplication] openURL:url];
        return NO;
    }
    else{
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://wpa.qq.com/msgrd?v=3&uin=%@&site=qq&menu=yes",qq]]];
        return YES;
    }
}


// 点击查看大图
-(void) imgTouchUpInside:(UITapGestureRecognizer *)recognizer{
    UIImageView *_picView=(UIImageView*)recognizer.view;
    
    CALayer *calayer = _picView.layer.mask;
    [_picView.layer.mask removeFromSuperlayer];
    __weak ZCTextGuideCell *weakSelf = self;
    SobotXHImageViewer *xh=[[SobotXHImageViewer alloc] initWithImageViewerWillDismissWithSelectedViewBlock:^(SobotXHImageViewer *imageViewer, UIImageView *selectedView) {
        
    } didDismissWithSelectedViewBlock:^(SobotXHImageViewer *imageViewer, UIImageView *selectedView) {
        selectedView.layer.mask = calayer;
        [selectedView setNeedsDisplay];
        
        if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]){
            [weakSelf.delegate cellItemClick:weakSelf.tempModel type:ZCChatCellClickTypeTouchImageNO obj:self];
            //                        [self.delegate touchLagerImageView:xh with:NO];
        }
    } didChangeToImageViewBlock:^(SobotXHImageViewer *imageViewer, UIImageView *selectedView) {
        
    }];
    
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    [photos addObject:_picView];
    
    xh.delegate = self;
    xh.disableTouchDismiss = NO;
    _imageViewer = xh;
    
    [xh showWithImageViews:photos selectedView:_picView];
    
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
        ZCActionSheet *mysheet = [[ZCActionSheet alloc] initWithDelegate:self selectedColor:nil CancelTitle:ZCSTLocalString(@"取消") OtherTitles:ZCSTLocalString(@"保存图片"),@"识别二维码", nil];
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
    else if (buttonIndex == 2 && actionSheet.tag == 100){
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
    _lblEmojiQuestion.text = @"";
    
}



+(CGFloat)getCellHeight:(ZCLibMessage *)model time:(NSString *)showTime viewWith:(CGFloat )viewWidth{
    CGFloat cellheith = [super getCellHeight:model time:showTime viewWith:viewWidth];
    CGFloat maxWidth = viewWidth - 160;
    
    static UILabel *tempLabel = nil;
    if (!tempLabel) {
        tempLabel = [UILabel new];
        tempLabel.numberOfLines = 0;
        tempLabel.font = [ZCUITools zcgetKitChatFont];
        tempLabel.backgroundColor = [UIColor clearColor];
        tempLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        tempLabel.textColor = [UIColor whiteColor];
        
    }
    
    
    static ZCMLEmojiLabel *tempLabe = nil;
    if (!tempLabe) {
        tempLabe = [[ZCMLEmojiLabel alloc] initWithFrame:CGRectZero];
        tempLabe.numberOfLines = 0;
        tempLabe.font = [ZCUITools zcgetKitChatFont];
        tempLabe.backgroundColor = [UIColor clearColor];
        tempLabe.lineBreakMode = NSLineBreakByTruncatingTail;
        tempLabe.textColor = [UIColor whiteColor];
        tempLabe.isNeedAtAndPoundSign = YES;
        tempLabe.disableEmoji = NO;
        tempLabe.lineSpacing = 3.0f;
        tempLabe.verticalAlignment = ZCTTTAttributedLabelVerticalAlignmentCenter;
        //        tempLabel.textInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    }
    // 正在输入，需要放置加载动画图片
    NSString *text=model.richModel.msg;
    // 处理换行
    text = [text stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
    text = [text stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
    text = [text stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
    text = [text stringByReplacingOccurrencesOfString:@"<BR/>" withString:@"\n"];
    text = [text stringByReplacingOccurrencesOfString:@"<BR />" withString:@"\n"];
    text = [text stringByReplacingOccurrencesOfString:@"<p " withString:@"\n<p "];
    text = [text stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
    text = [text stringByReplacingOccurrencesOfString:@"<font color='red'>" withString:@"<a href=\"sobot://color\">"];
    text = [text stringByReplacingOccurrencesOfString:@"</font>" withString:@"</a>"];
    while ([text hasPrefix:@"\n"]) {
        text=[text substringWithRange:NSMakeRange(1, text.length-1)];
    }
    
    
    [ZCHtmlCore filterHtml:text result:^(NSString * _Nonnull text1, NSMutableArray * _Nonnull arr, NSMutableArray * _Nonnull links) {
        
        UIColor *linkColor = [ZCUITools zcgetChatRightlinkColor];
        if (text1 != nil && text1.length > 0) {
            tempLabe.attributedText =   [ZCHtmlFilter setHtml:text1 attrs:arr view: tempLabe textColor:[ZCUITools zcgetRightChatTextColor] textFont:[ZCUITools zcgetKitChatFont] linkColor:linkColor];
        }else{
            tempLabe.attributedText =   [[NSAttributedString alloc] initWithString:@""];
        }
        
        
    }];
    
    //    NSMutableDictionary *dict = [tempLabe getTextADict:text];
    //    if(dict){
    //        text = dict[@"text"];
    //    }
    //
    //    tempLabe.font = [ZCUITools zcgetKitChatFont];
    //    tempLabe.text = text;
    
    text = nil;
    //    dict = nil;
    cellheith = cellheith + 12;
    
    CGSize msgSize = [tempLabe preferredSizeWithMaxWidth:maxWidth];
    //    CGSize msgSize = [self autoHeightOfLabel:tempLabel with:maxWidth];
    // 如果图片不为空 先放置图片
    if (model.richModel.msgType >0 && !zcLibIs_null(model.richModel.richpricurl)) {
        
        cellheith = cellheith + MidImageHeight + 10 + Spaceheight;
        
        // 最多显示三行
        if(msgSize.height>70){
            msgSize.height = 70;
        }
    }
    
    cellheith = cellheith + msgSize.height +10 + Spaceheight;
    
    
    //判断显示标题
    if(![@"" isEqual:zcLibConvertToString(model.richModel.question)]){
        
        UIFontDescriptor *ctfFont = [ZCUITools zcgetKitChatFont].fontDescriptor;
        NSNumber *fontString = [ctfFont objectForKey:@"NSFontSizeAttribute"];
        tempLabe.font = [UIFont boldSystemFontOfSize:[fontString floatValue]];
        
        tempLabel.text = zcLibConvertToString(model.richModel.question);
        CGSize size = [tempLabe preferredSizeWithMaxWidth:maxWidth];
        
        cellheith = cellheith + size.height +10 + Spaceheight;
    }
    
    
    if (![@"" isEqualToString:zcLibConvertToString(model.richModel.answerStrip)]) {
        UIFontDescriptor *ctfFont = [ZCUITools zcgetKitChatFont].fontDescriptor;
        NSNumber *fontString = [ctfFont objectForKey:@"NSFontSizeAttribute"];
        tempLabe.font = [UIFont boldSystemFontOfSize:[fontString floatValue]];
        
        tempLabel.text = zcLibConvertToString(model.richModel.answerStrip);
        CGSize size = [tempLabe preferredSizeWithMaxWidth:maxWidth];
        
        cellheith = cellheith + size.height +10 + Spaceheight;
    }
    
    
    NSString *sugguestText=@"";
    
    // 引导说辞的阐述 添加stripe
    if (![@"" isEqualToString:zcLibConvertToString(model.richModel.stripe)]) {
        sugguestText = model.richModel.stripe;
    }
    
#pragma mark -- 引导建议
    // 添加建议
    if(model.richModel.multiModel.interfaceRetList!=nil && model.richModel.multiModel.interfaceRetList.count>0 && model.isHistory){
        
        int i=1;
        
        for (NSDictionary *item in model.richModel.multiModel.interfaceRetList) {
            NSString *linkString= [NSString stringWithFormat:@"• %@",item[@"title"]];
            
            if([sugguestText hasSuffix:@"\n"]){
                sugguestText=[NSString stringWithFormat:@"%@%@",sugguestText,linkString];
            }else{
                sugguestText=[NSString stringWithFormat:@"%@\n%@",sugguestText,linkString];
            }
            i=i+1;
        }
    }else  if(model.richModel.multiModel.interfaceRetList!=nil && model.richModel.multiModel.interfaceRetList.count>0){
        int i=1;
        
        for (NSDictionary *item in model.richModel.multiModel.interfaceRetList) {
            NSString *linkString = [NSString stringWithFormat:@"<a href=\"sobot://%d\">• %@</a>",i,item[@"title"]];
            
            if([sugguestText hasSuffix:@"\n"]){
                sugguestText=[NSString stringWithFormat:@"%@%@",sugguestText,linkString];
            }else{
                sugguestText=[NSString stringWithFormat:@"%@\n%@",sugguestText,linkString];
            }
            i=i+1;
            
        }
    }
    
    
    // 去掉尾部换行
    while ([sugguestText hasPrefix:@"\n"]) {
        sugguestText=[sugguestText substringWithRange:NSMakeRange(1, sugguestText.length-1)];
    }
    
    CGSize sugguestSize=CGSizeZero;
    if(![@"" isEqual:sugguestText]){
        
        [ZCHtmlCore filterHtml:text result:^(NSString * _Nonnull text1, NSMutableArray * _Nonnull arr, NSMutableArray * _Nonnull links) {
            if (text1 != nil && text1.length > 0) {
                tempLabe.attributedText =   [ZCHtmlFilter setHtml:text1 attrs:arr view:tempLabe textColor:[ZCUITools zcgetRightChatTextColor] textFont:[ZCUITools zcgetKitChatFont] linkColor:[ZCUITools zcgetChatRightlinkColor]];
            }else{
                tempLabe.attributedText =   [[NSAttributedString alloc] initWithString:@""];
            }
            
            
        }];
        
        //        NSMutableDictionary *sugguestDict = [tempLabe getTextADict:sugguestText];
        //        if(sugguestDict){
        //            sugguestText = sugguestDict[@"text"];
        //        }
        //        tempLabe.font = [ZCUITools zcgetKitChatFont];
        //        tempLabe.text = sugguestText;
        sugguestSize = [tempLabe preferredSizeWithMaxWidth:maxWidth];
        
        cellheith = cellheith + sugguestSize.height + Spaceheight + 10;
    }
    
    // 阅读全文
    if(model.richModel.msgType>0 && !zcLibIs_null(model.richModel.richmoreurl)){
        
        // 线条的高度
        cellheith = cellheith + 10 + Spaceheight + 1;
        
        tempLabel.font = [ZCUITools zcgetKitChatFont];
        tempLabel.text = ZCSTLocalString(@"查看详情");
        sugguestSize = [tempLabe preferredSizeWithMaxWidth:maxWidth];
        cellheith = cellheith + sugguestSize.height +10 + Spaceheight;
    }
    
    cellheith=cellheith + 10;
    
    return cellheith;
}



-(ZCLibConfig *) getZCLibConfig{
    //    return [ZCIMChat getZCIMChat].libConfig;
    return [[ZCPlatformTools sharedInstance] getPlatformInfo].config;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(NSString *)getQuestion:(NSDictionary *)model{
    if(model){
        NSMutableDictionary *recDict = [NSMutableDictionary dictionaryWithDictionary:model];
        [recDict removeObjectForKey:@"title"];
        return [ZCLocalStore DataTOjsonString:recDict];
    }
    return @"";
}

/**
 计算Label高度
 
 @param label 要计算的label，设置了值
 @param width label的最大宽度
 @param type 是否从新设置宽，1设置，0不设置
 */
- (CGSize )autoHeightOfLabel:(UILabel *)label with:(CGFloat )width{
    //Calculate the expected size based on the font and linebreak mode of your label
    // FLT_MAX here simply means no constraint in height
    CGSize maximumLabelSize = CGSizeMake(width, FLT_MAX);
    
    CGSize expectedLabelSize = [label sizeThatFits:maximumLabelSize];
    
    //adjust the label the the new height.
    CGRect newFrame = label.frame;
    newFrame.size.height = expectedLabelSize.height;
    label.frame = newFrame;
    [label updateConstraintsIfNeeded];
    
    return expectedLabelSize;
}

/**
 计算Label高度
 
 @param label 要计算的label，设置了值
 @param width label的最大宽度
 @param type 是否从新设置宽，1设置，0不设置
 */
+ (CGSize )autoHeightOfLabel:(UILabel *)label with:(CGFloat )width{
    //Calculate the expected size based on the font and linebreak mode of your label
    // FLT_MAX here simply means no constraint in height
    CGSize maximumLabelSize = CGSizeMake(width, FLT_MAX);
    
    CGSize expectedLabelSize = [label sizeThatFits:maximumLabelSize];
    
    //adjust the label the the new height.
    CGRect newFrame = label.frame;
    newFrame.size.height = expectedLabelSize.height;
    label.frame = newFrame;
    [label updateConstraintsIfNeeded];
    
    return expectedLabelSize;
}


@end
