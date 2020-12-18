//
//  ZCMultiRichCell.m
//  SobotKit
//
//  Created by lizhihui on 2017/12/6.
//  Copyright © 2017年 zhichi. All rights reserved.
//

#import "ZCMultiRichCell.h"
#import "ZCUIImageView.h"
#import "ZCLibGlobalDefine.h"
#import "ZCUIToastTools.h"
#import "ZCUIColorsDefine.h"
#import "ZCPlatformTools.h"
#import "ZCIMChat.h"
#define MidImageHeight 110
#import "ZCHtmlCore.h"
#import "ZCHtmlFilter.h"


@interface ZCMultiRichCell()<ZCMLEmojiLabelDelegate,UIGestureRecognizerDelegate>{
    NSString    *callURL;
    ZCMLEmojiLabel *_lblEmojiQuestion;// 标题
    ZCMLEmojiLabel *_lblTextMsg; // 描述
    ZCUIImageView *_middleImageView; // 图片
    ZCMLEmojiLabel *_lookMoreLabel; // 展开
    UIView       * _lineView; // 线条
    NSString * morelink;
}

@end

@implementation ZCMultiRichCell


#pragma mark -- 创建子控件

#pragma mark - getter
- (ZCMLEmojiLabel *)lblTextMsg // 中间的消息体
{
    if (!_lblTextMsg) {
        _lblTextMsg = [ZCMLEmojiLabel new];
        _lblTextMsg.numberOfLines = 0;
        _lblTextMsg.font = [ZCUITools zcgetKitChatFont];
        _lblTextMsg.delegate = self;
        _lblTextMsg.lineBreakMode = NSLineBreakByTruncatingTail;
        _lblTextMsg.textColor = [UIColor whiteColor];
        _lblTextMsg.backgroundColor = [UIColor clearColor];
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
        _lblEmojiQuestion = [ZCMLEmojiLabel new];
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

-(ZCUIImageView *)middleImageView{
    if(!_middleImageView){
        _middleImageView=[[ZCUIImageView alloc] init];
        [_middleImageView setBackgroundColor:[UIColor clearColor]];
        [_middleImageView setContentMode:UIViewContentModeScaleAspectFill];
        _middleImageView.layer.masksToBounds=YES;
        [self.contentView addSubview:_middleImageView];
    }
    return _middleImageView;
}


- (ZCMLEmojiLabel *)lookMoreLabel // 展开
{
    if (!_lookMoreLabel) {
        _lookMoreLabel = [ZCMLEmojiLabel new];
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

// 当前cell 的宽度是固定的  有无图片都是一样

-(CGFloat) InitDataToView:(ZCLibMessage *)model time:(NSString *)showTime{
    CGFloat bgY=[super InitDataToView:model time:showTime];
    
    [self textLabel].text = @"";
    
    CGRect questionF = CGRectZero;
    CGRect msgF = CGRectZero;
    CGRect imgF = CGRectZero;
    CGRect linF = CGRectZero;
    CGRect moreF = CGRectZero;
    
    for (UIView *v in self.ivBgView.subviews) {
        [v removeFromSuperview];
    }
    NSMutableDictionary * detailDict = model.richModel.multiModel.interfaceRetList.firstObject; // 多个
#pragma mark  -- 图片
    CGFloat height = 0;

    // 处理图片  当前的图片高度固定110
    if(![@"" isEqualToString:zcLibConvertToString(detailDict[@"thumbnail"])]){
        [[self middleImageView] loadWithURL:[NSURL URLWithString:zcUrlEncodedString(detailDict[@"thumbnail"])] placeholer:nil showActivityIndicatorView:YES];
        [self middleImageView].hidden=NO;
        [self middleImageView].userInteractionEnabled=YES;
        imgF = CGRectMake(GetCellItemX(self.isRight), height, self.viewWidth -160, MidImageHeight);
        [self.middleImageView setFrame:imgF];
        height = height + MidImageHeight + 10 + Spaceheight;
    }
    
#pragma mark 标题
    NSString *question = zcLibConvertToString(detailDict[@"title"]);
    
    if(![@"" isEqual:question]){
        [self lblEmojiQuestion].text = @"";
    }
    
    // 必须在赋值之前设置
    if(self.isRight){
        [self.lblTextMsg setTextColor:[ZCUITools zcgetRightChatTextColor]];
        [self.lblTextMsg setLinkColor:[ZCUITools zcgetChatRightlinkColor]];
        
        if(![@"" isEqual:question]){
            [self.lblEmojiQuestion setTextColor:[ZCUITools zcgetRightChatTextColor]];
            [self.lblEmojiQuestion setLinkColor:[ZCUITools zcgetChatRightlinkColor]];
        }
    }else{
        [self.lblTextMsg setTextColor:[ZCUITools zcgetLeftChatTextColor]];
        [self.lblTextMsg setLinkColor:[ZCUITools zcgetChatLeftLinkColor]];
        
        if(![@"" isEqual:question]){
            [self.lblEmojiQuestion setTextColor:[ZCUITools zcgetLeftChatTextColor]];
            [self.lblEmojiQuestion setLinkColor:[ZCUITools zcgetChatLeftLinkColor]];
        }
    }

    //判断显示标题
    if(![@"" isEqual:question]){
        self.lblEmojiQuestion.text  = question;
        CGSize size = [self.lblEmojiQuestion preferredSizeWithMaxWidth:self.maxWidth];
        
        questionF = CGRectMake(GetCellItemX(self.isRight), height, size.width, size.height);
        [[self lblEmojiQuestion] setFrame:questionF];
        
//        rw = size.width;
        height = height + size.height + 10 + Spaceheight;
    }
    
#pragma mark -- 中间的文本内容详情，如果图片是显示的，最多显示3行
    
    if (![@"" isEqualToString:zcLibConvertToString(detailDict[@"summary"])]) {
        NSString *text  =  zcLibConvertToString(zcLibConvertToString(detailDict[@"summary"]));
        
        [ZCHtmlCore filterHtml:text result:^(NSString * _Nonnull text1, NSMutableArray * _Nonnull arr, NSMutableArray * _Nonnull links) {
            if (self.isRight) {
                if (text1 != nil && text1.length > 0) {
                  self.lblTextMsg.attributedText =   [ZCHtmlFilter setHtml:text1 attrs:arr view:self.lblTextMsg textColor:[ZCUITools zcgetRightChatTextColor] textFont:[ZCUITools zcgetKitChatFont] linkColor:[ZCUITools zcgetChatRightlinkColor]];
                }else{
                    self.lblTextMsg.attributedText =   [[NSAttributedString alloc] initWithString:@""];
                }
                
            }else{
                if (text1 != nil && text1.length > 0) {
                    self.lblTextMsg.attributedText =    [ZCHtmlFilter setHtml:text1 attrs:arr view:self.lblTextMsg textColor:[ZCUITools zcgetLeftChatTextColor] textFont:[ZCUITools zcgetKitChatFont] linkColor:[ZCUITools zcgetChatLeftLinkColor]];
                }else{
                    self.lblTextMsg.attributedText =   [[NSAttributedString alloc] initWithString:@""];
                }
                
            }
        }];
        
        // 处理换行
//        text = [text stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
//        text = [text stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
//        text = [text stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
//        text = [text stringByReplacingOccurrencesOfString:@"<BR/>" withString:@"\n"];
//        text = [text stringByReplacingOccurrencesOfString:@"<BR />" withString:@"\n"];
//        text = [text stringByReplacingOccurrencesOfString:@"<p " withString:@"\n<p "];
//        text = [text stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
//        while ([text hasPrefix:@"\n"]) {
//            text=[text substringWithRange:NSMakeRange(1, text.length-1)];
//        }
//
//        NSMutableDictionary *dict = [self.lblTextMsg getTextADict:text];
//        if(dict){
//            text = dict[@"text"];
//        }
//
//        _lblTextMsg.text = text;
//        if(dict){
//            NSArray *arr = dict[@"arr"];
//            for (NSDictionary *item in arr) {
//                NSString *text = item[@"htmlText"];
//                int loc = [item[@"realFromIndex"] intValue];
//                // 一定要在设置text文本之后设置
//                [_lblTextMsg addLinkToURL:[NSURL URLWithString:item[@"url"]] withRange:NSMakeRange(loc, text.length)];
//            }
//        }
        CGSize size = [self.lblTextMsg preferredSizeWithMaxWidth:self.maxWidth];
//        if(rw < size.width){
//            rw = size.width;
//        }
        
        // 如果显示图片，文本最多显示3行
        if(![@"" isEqualToString:zcLibConvertToString(detailDict[@"thumbnail"])]){
            // 最多显示三行
            if(size.height>70){
                size.height = 70;
            }
        }
        msgF = CGRectMake(GetCellItemX(self.isRight), height, size.width, size.height);
        [[self textLabel] setFrame:msgF];
        
        height = height + size.height +10 + Spaceheight;
    }
    
    //设置线条 和展开
    if (![@"" isEqualToString:zcLibConvertToString(detailDict[@"anchor"])] ||
        ([@"" isEqualToString: zcLibConvertToString(detailDict[@"thumbnail"])] &&
          [@"" isEqualToString: zcLibConvertToString(detailDict[@"summary"]) ] &&
          [@"" isEqualToString: zcLibConvertToString(detailDict[@"title"])])) {
        
            // 添加线条
            _lineView  = [[UIView alloc]init];
            linF = CGRectMake(GetCellItemX(self.isRight), height, ScreenWidth -160, 1);
            [_lineView setFrame:linF];
            _lineView.backgroundColor = [ZCUITools zcgetLineRichColor];
            [self.contentView addSubview:_lineView];
            
            
        if (!([@"" isEqualToString: zcLibConvertToString(detailDict[@"thumbnail"])] &&
                [@"" isEqualToString: zcLibConvertToString(detailDict[@"summary"]) ] &&
                [@"" isEqualToString: zcLibConvertToString(detailDict[@"title"])])) {
            // 这三项 全为空的时候不添加 线条
            _lineView.hidden = NO;
            height = height + 10 + Spaceheight + 1;
        }else{
            _lineView.hidden = YES;
        }
        
        if (self.isRight) {
            [self.lookMoreLabel setTextColor:[ZCUITools zcgetRightChatTextColor]];
            [self.lookMoreLabel setLinkColor:[ZCUITools zcgetChatRightlinkColor]];
        }else{
            [self.lookMoreLabel setLinkColor:[ZCUITools zcgetChatMultLinkColor]];
            [self.lookMoreLabel setTextColor:[ZCUITools zcgetLeftChatTextColor]];
        }
        self.lookMoreLabel.hidden = NO;
        self.lookMoreLabel.text = ZCSTLocalString(@"查看详情");
//        if (!model.richModel.multiModel.isHistoryMessages) {
            // 一定要在设置text文本之后设置
            [[self lookMoreLabel] addLinkToURL:[NSURL URLWithString:zcLibConvertToString(detailDict[@"anchor"])] withRange:NSMakeRange(0, ZCSTLocalString(@"查看详情").length)];
            morelink = zcLibConvertToString(detailDict[@"anchor"]);
//        }
        CGSize size = [[self lookMoreLabel]preferredSizeWithMaxWidth:self.maxWidth];
        moreF = CGRectMake(GetCellItemX(self.isRight), height, size.width, size.height);
        [[self lookMoreLabel] setFrame:moreF];
        height = height + size.height ;
    }
    
    CGFloat msgX = 0;
     msgX = 78;
    
    [self.ivBgView setFrame:CGRectMake(58, bgY, self.maxWidth, height +10)];
    
    if(questionF.size.height>0){
        questionF.origin.x = msgX;
        questionF.origin.y = questionF.origin.y + bgY;
        [self.lblEmojiQuestion setFrame:questionF];
    }
    
    msgF.origin.x = msgX;
    msgF.origin.y =  msgF.origin.y + bgY - 10;

    // 如果是不是富文本消息 整个 Y值增加间距 上间距
    if (![@"" isEqualToString:zcLibConvertToString(detailDict[@"thumbnail"])] || [@"" isEqual:question] ) {
        msgF.origin.y += 10;
    }
    // 设置详情文本的frame
    [self.lblTextMsg setFrame:msgF];
    
    if(imgF.size.height>0){
        imgF.origin.x = CGRectGetMaxX(self.ivBgView.frame) - CGRectGetWidth(self.ivBgView.frame) + 8;
        imgF.origin.y = imgF.origin.y + bgY;
        imgF.size.width = CGRectGetWidth(self.ivBgView.frame) -8;
        [self.middleImageView setFrame:imgF];
    }
    
    if (linF.size.height >0) {
        linF.origin.x = self.ivBgView.frame.origin.x + 8;
        linF.origin.y = linF.origin.y + bgY;
        linF.size.width = CGRectGetWidth(self.ivBgView.frame) -8;

        [_lineView setFrame:linF];
        
    }
    
    // 重新设置展开的frame
    if (moreF.size.height >0) {
        moreF.origin.x =   CGRectGetMaxX(_lineView.frame) - CGRectGetWidth(_lookMoreLabel.frame) -5;
        moreF.origin.y = moreF.origin.y +bgY;
        [[self lookMoreLabel] setFrame:moreF];
    }
    
   
    
    if (model.richModel.multiModel.isHistoryMessages) {
        [self.ivBgView setBackgroundColor:UIColorFromRGB(multiWheelBgColor)];
    }else{
        [self.ivBgView setBackgroundColor:[ZCUITools zcgetLeftChatColor]];
    }
    
//    CGFloat sh = [self setSendStatus:self.ivBgView.frame];
    
    // 设置尖角
    [self.ivLayerView setFrame:self.ivBgView.frame];
    CALayer *layer              = self.ivLayerView.layer;
    layer.frame                 = (CGRect){{0,0},self.ivLayerView.layer.frame.size};
    self.ivBgView.layer.mask = layer;
    [self.ivBgView setNeedsDisplay];
    
    
    [self setFrame:CGRectMake(0, 0, self.viewWidth, height+bgY )];
    return height+bgY + 10 ;
}

#pragma mark - gesture delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"ZCMLEmojiLabel"]) {
        
        if(![@"" isEqualToString:morelink ] && morelink!= nil && self.delegate && [self.delegate respondsToSelector:@selector(cellItemLinkClick:type:obj:)]){
            [self.delegate cellItemLinkClick:self.lookMoreLabel.text type:ZCChatCellClickTypeOpenURL obj:morelink];
        }
    }
    return YES;

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
        if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemLinkClick:type:obj:)]){
            [self.delegate cellItemLinkClick:htmlText type:ZCChatCellClickTypeOpenURL obj:url];
        }
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
    
    NSMutableDictionary * detailDict = model.richModel.multiModel.interfaceRetList.firstObject;
    
    static ZCMLEmojiLabel *tempLabel = nil;
    
    if (![@"" isEqualToString:zcLibConvertToString(detailDict[@"thumbnail"])]) {
        cellheith = cellheith + MidImageHeight + 10 + Spaceheight;
    }
    
    //判断显示标题
    if(![@"" isEqual:zcLibConvertToString(detailDict[@"title"])]){
        
        UIFontDescriptor *ctfFont = [ZCUITools zcgetKitChatFont].fontDescriptor;
        NSNumber *fontString = [ctfFont objectForKey:@"NSFontSizeAttribute"];
        tempLabel.font = [UIFont boldSystemFontOfSize:[fontString floatValue]];
        
        tempLabel.text = zcLibConvertToString(model.richModel.question);
        CGSize size = [tempLabel preferredSizeWithMaxWidth:maxWidth];
        
        cellheith = cellheith + size.height +10 + Spaceheight;
    }
    
    
    // 摘要
    if (![@"" isEqualToString:zcLibConvertToString(detailDict[@"summary"])]) {
        
        if (!tempLabel) {
            tempLabel = [ZCMLEmojiLabel new];
            tempLabel.numberOfLines = 0;
            tempLabel.font = [ZCUITools zcgetKitChatFont];
            tempLabel.backgroundColor = [UIColor clearColor];
            tempLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            tempLabel.textColor = [UIColor whiteColor];
            tempLabel.isNeedAtAndPoundSign = YES;
            tempLabel.disableEmoji = NO;
            tempLabel.lineSpacing = 3.0f;
            tempLabel.verticalAlignment = ZCTTTAttributedLabelVerticalAlignmentCenter;
        }
        // 正在输入，需要放置加载动画图片
        NSString *text=model.richModel.msg;
        
        [ZCHtmlCore filterHtml:text result:^(NSString * _Nonnull text1, NSMutableArray * _Nonnull arr, NSMutableArray * _Nonnull links) {
//            if (self.isRight) {
            if (text1 != nil && text1.length > 0) {
                tempLabel.attributedText =   [ZCHtmlFilter setHtml:text1 attrs:arr view:tempLabel textColor:[ZCUITools zcgetRightChatTextColor] textFont:[ZCUITools zcgetKitChatFont] linkColor:[ZCUITools zcgetChatRightlinkColor]];
            }else{
                tempLabel.attributedText =  [[NSAttributedString alloc] initWithString:@""];
            }
            
//            }else{
//                tempLabel.attributedText =    [ZCHtmlFilter setHtml:text1 attrs:arr view:tempLabel textColor:[ZCUITools zcgetLeftChatTextColor] textFont:[ZCUITools zcgetKitChatFont] linkColor:[ZCUITools zcgetChatLeftLinkColor]];
//            }
        }];
        
        // 处理换行
//        text = [text stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
//        text = [text stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
//        text = [text stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
//        text = [text stringByReplacingOccurrencesOfString:@"<BR/>" withString:@"\n"];
//        text = [text stringByReplacingOccurrencesOfString:@"<BR />" withString:@"\n"];
//        text = [text stringByReplacingOccurrencesOfString:@"<p " withString:@"\n<p "];
//        text = [text stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
//        while ([text hasPrefix:@"\n"]) {
//            text=[text substringWithRange:NSMakeRange(1, text.length-1)];
//        }
//        NSMutableDictionary *dict = [tempLabel getTextADict:text];
//        if(dict){
//            text = dict[@"text"];
//        }
//
//        tempLabel.font = [ZCUITools zcgetKitChatFont];
//        tempLabel.text = text;
        
        text = nil;
//        dict = nil;

        
        CGSize msgSize = [tempLabel preferredSizeWithMaxWidth:maxWidth];
        
        // 最多显示三行
        if(msgSize.height>70){
            msgSize.height = 70;
        }
    
        
        cellheith = cellheith + msgSize.height +10 + Spaceheight;
    }

  
    // 阅读全文
    if(![@"" isEqualToString:zcLibConvertToString(detailDict[@"anchor"])] ||
       ([@"" isEqualToString: zcLibConvertToString(detailDict[@"thumbnail"])] &&
        [@"" isEqualToString: zcLibConvertToString(detailDict[@"summary"]) ] &&
        [@"" isEqualToString: zcLibConvertToString(detailDict[@"title"])])){
           if (!([@"" isEqualToString: zcLibConvertToString(detailDict[@"thumbnail"])] &&
                 [@"" isEqualToString: zcLibConvertToString(detailDict[@"summary"]) ] &&
                 [@"" isEqualToString: zcLibConvertToString(detailDict[@"title"])])) {
             
               // 线条的高度
               cellheith = cellheith + 10 + Spaceheight + 1;
           }
           
        tempLabel.font = [ZCUITools zcgetKitChatFont];
        tempLabel.text = ZCSTLocalString(@"查看详情");
        CGSize size = [tempLabel preferredSizeWithMaxWidth:ScreenWidth -160]; // 展开的高度
        cellheith = cellheith + 10 + Spaceheight + 1 + size.height;
    }
    
    cellheith = cellheith + 10 + 10 + 12;
    
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

@end
