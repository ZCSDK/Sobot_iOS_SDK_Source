//
//  ZCNoticeCell.m
//  SobotKit
//
//  Created by lizhihui on 2019/3/26.
//  Copyright © 2019 zhichi. All rights reserved.
//

#import "ZCNoticeCell.h"
#import "ZCButton.h"
#import "ZCLibGlobalDefine.h"
#import "ZCUIColorsDefine.h"
#import "ZCHtmlCore.h"
#import "ZCHtmlFilter.h"


typedef NS_ENUM(NSUInteger,ZCNoticeStatus){
    ZCNoticeStatusOpen       = 1,           // 展开
    ZCNoticeStatusPackUp     = 2,          // 收起
};

@interface ZCNoticeCell()<ZCMLEmojiLabelDelegate>{
    ZCMLEmojiLabel *_lblTextMsg;
    ZCButton * _lookBtn;
    UIImageView * _imgIcon;
    UIView * _bgView ;//背景View
     NSString    *callURL;
}



@end

@implementation ZCNoticeCell

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
    return ![_lblTextMsg containslinkAtPoint:[touch locationInView:_lblTextMsg]];
}

-(ZCMLEmojiLabel *)lblTextMsg{ // 消息内容
    if (!_lblTextMsg) {
        _lblTextMsg = [[ZCMLEmojiLabel alloc] initWithFrame:CGRectZero];
        _lblTextMsg.numberOfLines = 0;
        _lblTextMsg.font = ZCUIFont14;
        _lblTextMsg.delegate = self;
        _lblTextMsg.lineBreakMode = NSLineBreakByTruncatingTail;
        _lblTextMsg.backgroundColor = [UIColor clearColor];

        _lblTextMsg.isNeedAtAndPoundSign = NO;
        _lblTextMsg.disableEmoji = NO;
        
        _lblTextMsg.lineSpacing = 3.0f;
        
        _lblTextMsg.verticalAlignment = ZCTTTAttributedLabelVerticalAlignmentCenter;
        [self.bgView addSubview:_lblTextMsg];
    }
    return _lblTextMsg;
}

-(ZCButton *)lookBtn{
    if (!_lookBtn) {
        _lookBtn = [ZCButton buttonWithType:UIButtonTypeCustom];
//        [_lookBtn setTitle:@"展开" forState:UIControlStateNormal];
        [_lookBtn setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_triangle_down"] forState:UIControlStateNormal];
        _lookBtn.type = 4;
        _lookBtn.tag = ZCNoticeStatusOpen;
        [_lookBtn addTarget:self action:@selector(openBtnAction:) forControlEvents:UIControlEventTouchUpInside];
//        _lookBtn.titleLabel.font = ZCUIFont14;
        [_bgView addSubview:_lookBtn];
        _lookBtn.hidden = YES;
        
    }
    return _lookBtn;
}

-(UIView *)bgView{
    if (!_bgView) {
        _bgView = [[UIView alloc]init];
        _bgView.backgroundColor = [ZCUITools getNotifitionTopViewBgColor];
        //UIColorFromRGB(noticBgColor);
        _bgView.layer.cornerRadius = 5;
        _bgView.layer.masksToBounds = YES;
        [self.contentView addSubview:_bgView];
    }
    return _bgView;
}

-(UIImageView*)imgIcon{
    if (!_imgIcon) {
        _imgIcon = [[UIImageView alloc]init];
        _imgIcon.image = [ZCUITools zcuiGetBundleImage:@"zcicon_annunciate"];
        [_bgView addSubview:_imgIcon];
    }
    return _imgIcon;
}

-(void)openBtnAction:(UIButton *)sender{
   
    if (sender.tag == ZCNoticeStatusOpen) {
        _lookBtn.tag = ZCNoticeStatusPackUp;
//        [_lookBtn setTitle:@"收起" forState:UIControlStateNormal];
        [_lookBtn setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_triangle_up"] forState:UIControlStateNormal];
    }else if (sender.tag == ZCNoticeStatusPackUp){
        _lookBtn.tag = ZCNoticeStatusOpen;
//        [_lookBtn setTitle:@"展开" forState:UIControlStateNormal];
        [_lookBtn setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_triangle_down"] forState:UIControlStateNormal];
    }
    
    
    if (self.delegate &&[self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]) {
        [self.delegate cellItemClick:[ZCLibMessage new] type:ZCChatCellClickTypeNotice obj:[NSString stringWithFormat:@"%zd",sender.tag]];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


-(CGFloat) InitDataToView:(ZCLibMessage *)model time:(NSString *)showTime{
    [self resetCellView];
    
  [super InitDataToView:model time:showTime];
    CGFloat cellHeight = 10;
    _lookBtn.hidden = YES;
    [self lblTextMsg].text = @"";
    self.ivHeader.hidden = YES;
    CGRect ltF = CGRectZero;
    CGRect BF = CGRectZero;
    CGRect BgF = CGRectZero;
    self.bgView.frame = BgF;
    CGFloat rw = 0;
    
     rw = self.viewWidth - ZCNumber(51 + 25);
    
    for (UIView *v in self.ivBgView.subviews) {
        [v removeFromSuperview];
    }
    float imgIconY = ZCNumber(14);
    NSString *deviceType = [UIDevice currentDevice].model;
    if([deviceType isEqualToString:@"iPad"]){
        imgIconY = 15;
    }
    self.imgIcon.frame = CGRectMake(ZCNumber(14), imgIconY, 13, 13);
    NSString * text = sobotConvertToString(model.richModel.msg);
    
    [ZCHtmlCore filterHtml:text result:^(NSString * _Nonnull text1, NSMutableArray * _Nonnull arr, NSMutableArray * _Nonnull links) {
        if (text1 != nil && text1.length > 0) {
            _lblTextMsg.attributedText =   [ZCHtmlFilter setHtml:text1 attrs:arr view:_lblTextMsg textColor:UIColorFromThemeColor(ZCTextNoticeColor) textFont:ZCUIFont14 linkColor:UIColorFromThemeColor(ZCTextNoticeLinkColor)];
            
        }else{
            _lblTextMsg.attributedText =   [[NSAttributedString alloc] initWithString:@""];
            
        }
        
    }];
    
    CGSize size = [_lblTextMsg preferredSizeWithMaxWidth:self.viewWidth -ZCNumber(76)];
    
   
    
    // 如果显示图片，文本最多显示3行
    BOOL  isShowBtn = NO;
    if (size.height > ZCNumber(120)) {
        isShowBtn = YES;
    }
    
    if(text.length > 0 && self.lookBtn.tag == ZCNoticeStatusOpen){
        // 最多显示三行
        if(size.height>ZCNumber(120)){
            size.height =ZCNumber(120);
        }
    }
   
    ltF = CGRectMake(CGRectGetMaxX(self.imgIcon.frame) +ZCNumber(10), cellHeight - 2, size.width, size.height);
    [[self lblTextMsg] setFrame:ltF];
    
    cellHeight = cellHeight + size.height +ZCNumber(3) + Spaceheight;
    
    CGFloat  btnH = 0;
    if (isShowBtn) {
        btnH = 20;
        _lookBtn.hidden = NO;
    }
    BF = CGRectMake((self.viewWidth - 30)/2 - 20 , cellHeight, 40, btnH);
    self.lookBtn.frame = BF;
    
    BgF = CGRectMake(ZCNumber(12), ZCNumber(12), self.viewWidth - ZCNumber(24), CGRectGetMaxY(self.lookBtn.frame)+  (isShowBtn? ZCNumber(5):5));
    self.bgView.frame = BgF;
    


    cellHeight = CGRectGetMaxY(self.bgView.frame) ;
    
    
    if (![showTime isEqualToString:@""]) {
        self.lblTime.hidden = NO;
        self.lblTime.frame = CGRectMake(0, cellHeight + ZCNumber(15), self.viewWidth, 30);
        cellHeight = cellHeight + ZCNumber(15) + 30 + 10 + Spaceheight;
     }
    
    
    self.frame = CGRectMake(0, 0, self.viewWidth, cellHeight);
    
    return cellHeight;
    
    
}


+(CGFloat)getCellHeight:(ZCLibMessage *)model time:(NSString *)showTime viewWith:(CGFloat)width{
    
    CGFloat cellHeight = 12;
    
    CGRect ltF = CGRectZero;
    CGRect BF = CGRectZero;
    CGRect BgF = CGRectZero;
   

    CGRect imgF = CGRectMake(ZCNumber(10), ZCNumber(14), 13, 13);
    
    static ZCMLEmojiLabel *tempLabel = nil;
    if (!tempLabel) {
        tempLabel = [[ZCMLEmojiLabel alloc] initWithFrame:CGRectZero];
        tempLabel.numberOfLines = 0;
        tempLabel.font = ZCUIFont14;
        tempLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        tempLabel.textColor = [UIColor whiteColor];
        tempLabel.backgroundColor = [UIColor clearColor];
        tempLabel.isNeedAtAndPoundSign = NO;
        tempLabel.disableEmoji = NO;
        tempLabel.lineSpacing = 3.0f;
        tempLabel.verticalAlignment = ZCTTTAttributedLabelVerticalAlignmentCenter;
    }
    
    NSString * text = sobotConvertToString(model.richModel.msg);

    [ZCHtmlCore filterHtml:text result:^(NSString * _Nonnull text1, NSMutableArray * _Nonnull arr, NSMutableArray * _Nonnull links) {
        if (text1 != nil && text1.length > 0) {
//            tempLabel.attributedText =   [ZCHtmlFilter setHtml:text1 attrs:arr view:tempLabel textColor:UIColorFromRGB(0x6D6A69) textFont:ZCUIFont14 linkColor:UIColorFromRGB(0xE67F17)];
            
            tempLabel.attributedText =   [ZCHtmlFilter setHtml:text1 attrs:arr view:tempLabel textColor:UIColorFromThemeColor(ZCTextNoticeColor) textFont:ZCUIFont14 linkColor:UIColorFromThemeColor(ZCTextNoticeLinkColor)];

            
        }else{
            tempLabel.attributedText =  [[NSAttributedString alloc] initWithString:@""];
        }
       
        
    }];
    
    CGSize size = [tempLabel preferredSizeWithMaxWidth:width -ZCNumber(76)];
   
    BOOL isShowBtn = NO;
    if (size.height > 120) {
        isShowBtn = YES;
    }
    
    // 如果显示图片，文本最多显示3行
    if(!model.isOpenNotice){
        // 最多显示三行
        if(size.height>120){
            size.height = 120;
        }
    }
    
    ltF = CGRectMake(imgF.origin.x + imgF.size.width +ZCNumber(16), cellHeight, size.width, size.height);
    [tempLabel setFrame:ltF];
    
    cellHeight = cellHeight + size.height +ZCNumber(3) + Spaceheight;
    
    CGFloat btnH = 0;
    if (isShowBtn) {
        btnH = 20;
    }
     BF = CGRectMake(ZCNumber(300), cellHeight, 30, btnH);
    
    BgF = CGRectMake(ZCNumber(15), ZCNumber(12), width - ZCNumber(30), BF.origin.y + BF.size.height + (isShowBtn? ZCNumber(8):5));
    
    cellHeight = BgF.origin.y + BgF.size.height + 10 + Spaceheight;
    
    if (![showTime isEqualToString:@""]) {
       // 处理时间的高度
        cellHeight = cellHeight + ZCNumber(15) + 10;
    }
    
    
    
    return cellHeight;
    
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
            if(index > 0 && self.tempModel.richModel.suggestionArr.count>=index){
                if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]){
                    [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeItemChecked obj:[NSString stringWithFormat:@"%d",index-1]];
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




- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
