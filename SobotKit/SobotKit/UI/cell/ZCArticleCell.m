//
//  ZCArticleCell.m
//  SobotKit
//
//  Created by lizh on 2022/8/29.
//  Copyright © 2022 zhichi. All rights reserved.
//

#import "ZCArticleCell.h"
#import "ZCLibGlobalDefine.h"
#import "ZCUIColorsDefine.h"
#import "SobotXHImageViewer.h"
#import "SobotImageView.h"
#import "ZCStoreConfiguration.h"
#import "ZCUICore.h"
#import "ZCMLEmojiLabel.h"
#import "ZCHtmlCore.h"
@interface ZCArticleCell()<ZCMLEmojiLabelDelegate>
{
    ZCLibMessage *_model;
    NSString *morelink;
}

@property (nonatomic,strong) UIView *bgView;
@property (nonatomic,strong) SobotImageView *logoView;
@property (nonatomic,strong) UILabel *titleLab;
@property (nonatomic,strong) UILabel *descLab;
@property (nonatomic,strong) ZCMLEmojiLabel *lookMoreLab;
@property (nonatomic,strong) SobotImageView *nextView;
@property (nonatomic,strong) UIView *lineView;
@property (nonatomic,strong) UIButton *clickBtn;
@property (nonatomic,strong) ZCMLEmojiLabel *suglabel;
@end

@implementation ZCArticleCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        _bgView = [[UIView alloc]init];
        _bgView.layer.cornerRadius = 5.0;
        _bgView.layer.masksToBounds = YES;
        _bgView.frame = CGRectMake(0, 0, self.viewWidth - 100, 257);
        _bgView.backgroundColor = UIColorFromThemeColor(ZCBgSystemWhiteColor);
        _bgView.layer.borderColor = UIColorFromThemeColor(ZCBgLineColor).CGColor;
        _bgView.layer.borderWidth = 0.5;
        [self.contentView addSubview:_bgView];
        
        _logoView = [[SobotImageView alloc]init];
        _logoView.frame = CGRectMake(0, 0, self.viewWidth - 100, 137);
        [_logoView setContentMode:UIViewContentModeScaleAspectFill];
        _logoView.layer.masksToBounds = YES;
        [_bgView addSubview:_logoView];
        
        // title
        _titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [_titleLab setTextAlignment:NSTextAlignmentLeft];
        [_titleLab setFont:ZCUIFont14];
        [_titleLab setTextColor:UIColorFromThemeColor(ZCArticleTitleTextColor)]; // 0x515a7c
        [_titleLab setBackgroundColor:[UIColor clearColor]];
        _titleLab.numberOfLines = 1;
        [_bgView addSubview:_titleLab];
        
        _descLab = [[UILabel alloc]init];
        _descLab.textColor = UIColorFromThemeColor(ZCTextMainColor);
        _descLab.font = ZCUIFont14;
        _descLab.numberOfLines = 2;
        _descLab.lineBreakMode = NSLineBreakByTruncatingTail;
        [_bgView addSubview:_descLab];
        
        _lookMoreLab = [[ZCMLEmojiLabel alloc] initWithFrame:CGRectZero];
        _lookMoreLab.numberOfLines = 0;
        _lookMoreLab.font = ZCUIFont14;
        _lookMoreLab.delegate = self;
        _lookMoreLab.lineBreakMode = NSLineBreakByTruncatingTail;
        _lookMoreLab.textColor = UIColorFromThemeColor(ZCTextMainColor);
        _lookMoreLab.isNeedAtAndPoundSign = NO;
        _lookMoreLab.disableEmoji = NO;
        _lookMoreLab.lineSpacing = 3.0f;
        [_bgView addSubview:_lookMoreLab];
        
        _lineView = [[UIView alloc]init];
        _lineView.backgroundColor = UIColorFromThemeColor(ZCBgLineColor);
        [_bgView addSubview:_lineView];
        
        _nextView = [[SobotImageView alloc]init];
        [_nextView setBackgroundColor:[UIColor clearColor]];
        [_nextView setContentMode:UIViewContentModeScaleAspectFill];
        [_nextView setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_arrow_reply"]];
        [_bgView addSubview:_nextView];
        
        _clickBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _clickBtn.frame = CGRectMake(0, 0, 320, 257);
        _clickBtn.backgroundColor = [UIColor clearColor];
        [_clickBtn addTarget:self action:@selector(jumpWebPage:) forControlEvents:UIControlEventTouchUpInside];
        [_bgView addSubview:_clickBtn];

    }
    return self;
}


-(CGFloat) InitDataToView:(ZCLibMessage *) model time:(NSString *) showTime{
    _model = model;
    [self resetCellView];
    _suglabel.text = @"";
    _suglabel = nil;
    // 时间
    CGFloat bgY=[super InitDataToView:model time:showTime];
    CGFloat bgFH = bgY;
    CGFloat maxWidth = self.viewWidth - 100;  // 卡片宽度固定 226
    if (maxWidth > 320) {
        maxWidth = 320;
    }
    
    CGFloat rw = maxWidth;
    if ([ZCChatBaseCell getStatusHeight:model] >0) {
        // 显示顶踩 固定最大宽度
        rw = maxWidth;
    }
    
    CGFloat cellHeight = 0;
    if (sobotConvertToString(model.richModel.articleSnapshot).length > 0) {
        // 有图
        _logoView.frame = CGRectMake(0, 0, rw , 137);
        cellHeight = cellHeight + 12 + 137;
        [_logoView loadWithURL:[NSURL URLWithString:sobotUrlEncodedString(model.richModel.articleSnapshot)] placeholer:[ZCUITools zcuiGetBundleImage:@"zcicon_default_goods_1"]  showActivityIndicatorView:YES];
    }else{
        _logoView.frame = CGRectMake(0, 0, 0, 0);
        cellHeight = cellHeight + 12;
    }
    
    // 标题
    _titleLab.frame = CGRectMake(15, cellHeight , rw - 30 , 20);
    _titleLab.text = sobotConvertToString(model.richModel.articleTitle);
    [_titleLab sizeToFit];
//    _titleLab.lineBreakMode = NSLineBreakByTruncatingMiddle;
    CGFloat th = _titleLab.frame.size.height;
    cellHeight = cellHeight + th;

    _descLab.frame = CGRectMake(15, cellHeight + 5, rw - 30 , 40);
    _descLab.text = sobotConvertToString(model.richModel.articleDesc);
    [_descLab sizeToFit];
//    _descLab.lineBreakMode = NSLineBreakByTruncatingMiddle;
    CGRect DF = _descLab.frame;
    if (DF.size.height > 40) {
        DF.size.height = 40;
    }
    _descLab.frame = DF;
    cellHeight = cellHeight + DF.size.height + 5;
    
    _lineView.frame = CGRectMake(15, cellHeight + 12, rw - 30 , 1);
    cellHeight = cellHeight + 13;
    
    _lookMoreLab.frame = CGRectMake(15, cellHeight + 4 , rw - 60, 22);
    _lookMoreLab.text = ZCSTLocalString(@"查看详情");
    _lookMoreLab.textAlignment = NSTextAlignmentLeft;
    morelink = sobotConvertToString(_model.richModel.articleRichMoreUrl);
    
    _nextView.frame = CGRectMake(rw -15 - 9 , cellHeight + 10, 5, 9);
    cellHeight = cellHeight + 30; // 最终高度

    
    // 这里查看是否有关联问题
    CGFloat h = 0;
    CGFloat lineSpace = [ZCUITools zcgetChatLineSpacing];
    // 记录实际最大宽度
    CGFloat contentWidth = rw;
    if (!self.isRight && sobotConvertToString([model getModelDisplaySugestionText]).length > 0) {
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
            [ZCArticleCell setDisplayAttributedString:model.displaySugestionattr label:_suglabel model:model guide:YES];
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
        CGRect f = CGRectMake(15+15, h - s.height - lineSpace + CGRectGetMaxY(self.bgView.frame) +10, s.width, s.height);
        _suglabel.frame = f;
        [self.contentView addSubview:_suglabel];
    }
    
    
    CGRect bgviewR = self.bgView.frame;
    bgviewR.origin.y = bgFH;
    CGFloat msgX = 0;
    if(self.isRight){
        int rx = self.viewWidth- rw - 15;
        msgX = rx + 15;
        bgviewR.origin.x = msgX;
        bgviewR.size.width = rw;
        self.bgView.frame = bgviewR;
        [self.ivBgView setFrame:CGRectMake(rx , bgFH, rw , cellHeight)];
    }else{
        float x = 15;
        msgX = x;
//        [self.ivBgView setFrame:CGRectMake(x, bgFH, rw , cellHeight)];
        bgviewR.origin.x = msgX;
        bgviewR.size.height = cellHeight;
        bgviewR.size.width = rw;
        self.bgView.frame = bgviewR;
        if (sobotConvertToString([model getModelDisplaySugestionText]).length == 0) {
            [self.ivBgView setFrame:CGRectMake(x, bgFH, rw , cellHeight )];
        }else{
            CGRect sulabF = self.suglabel.frame;
            sulabF.origin.y = CGRectGetMaxY(self.bgView.frame) + 10;
            self.suglabel.frame = sulabF;
            [self.ivBgView setFrame:CGRectMake(x, bgFH, contentWidth + 15 , cellHeight + 10 + sulabF.size.height + 20)];
            cellHeight = cellHeight + sulabF.size.height +10;
        }
    }
    self.clickBtn.frame = CGRectMake(0, 0, bgviewR.size.width, bgviewR.size.height);
    CGFloat sh = [self setSendStatus:self.ivBgView.frame];
    // 添加点踩和转人工
    [self isAddBottomBgView:self.ivBgView.frame msgIsOneLine:NO];
    if(model.includeSensitive > 0){
        // 右边气泡背景图片
        UIImage * bgImage = [ZCUITools zcuiGetBundleImage:@"zcicon_pop_green_normal_line"];
        bgImage=[bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(21, 21, 21, 21)];
        self.ivBgView.image = bgImage;
        self.ivBgView.backgroundColor = UIColorFromThemeColor(ZCBgSystemWhiteLightGrayColor);
        //设置尖角
        [self.ivLayerView setImage:bgImage];
    }
    self.ivBgView.contentMode = UIViewContentModeScaleToFill;
    // 设置尖角
    [self.ivLayerView setFrame:self.ivBgView.frame];
    CALayer *layer              = self.ivLayerView.layer;
    layer.frame                 = (CGRect){{0,0},self.ivLayerView.layer.frame.size};
    self.ivBgView.layer.mask = layer;
    [self.ivBgView setNeedsDisplay];
    [self setFrame:CGRectMake(0, 0, self.viewWidth, cellHeight + bgFH + sh + 20)];
    return cellHeight+ bgFH + 20 + sh;
}

#pragma mark - 获取高度
+(CGFloat)getCellHeight:(ZCLibMessage *)model time:(NSString *)showTime viewWith:(CGFloat )viewWidth{
    CGFloat cellHeight = [super getCellHeight:model time:showTime viewWith:viewWidth];
    CGFloat maxWidth = viewWidth - 100;
    if (maxWidth > 320) {
        maxWidth = 320;
    }
    CGFloat rw = maxWidth;
    if ([ZCChatBaseCell getStatusHeight:model] >0) {
        // 显示顶踩 固定最大宽度
        rw = maxWidth;
    }
    
    if (sobotConvertToString(model.richModel.articleSnapshot).length > 0) {
        // 有图片
        cellHeight = cellHeight + 137;
    }

    cellHeight = cellHeight + 12 + 20; // 标题高度

    // 描述
    UILabel *descLab = [[UILabel alloc]init];
    [descLab setTextAlignment:NSTextAlignmentLeft];
    [descLab setFont:ZCUIFont14];
    descLab.numberOfLines = 2;
    descLab.frame = CGRectMake(15, cellHeight +5, rw - 30, 40);
    descLab.text = sobotConvertToString(model.richModel.articleDesc);
    [descLab sizeToFit];
    CGFloat th = descLab.frame.size.height;
    if (th > 40) {
        th = 40;
    }
    cellHeight = cellHeight + th + 5;
    // 线条
    cellHeight = cellHeight + 13;
    // 查看更多
    cellHeight = cellHeight + 34;
  
    cellHeight = cellHeight +  [ZCChatBaseCell getStatusHeight:model];
    
    // 判断是否是一问多答中有关联问题
    if(sobotConvertToString([model getModelDisplaySugestionText]).length > 0){
        ZCMLEmojiLabel *slabel = [ZCChatBaseCell createRichLabel];
        UIColor *textColor = [ZCUITools zcgetLeftChatTextColor];
        UIColor *linkColor = [ZCUITools zcgetChatLeftLinkColor];
        if(model.displaySugestionattr!=nil){
            [ZCArticleCell setDisplayAttributedString:model.displaySugestionattr label:slabel model:model guide:YES];
        }else{
            [ZCHtmlCore filterHtml:[model getModelDisplaySugestionText] result:^(NSString * _Nonnull text1, NSMutableArray * _Nonnull arr, NSMutableArray * _Nonnull links) {
                if (text1 != nil && text1.length > 0) {
                    slabel.attributedText =    [ZCHtmlFilter setGuideHtml:text1 attrs:arr view:slabel textColor:textColor textFont:[ZCUITools zcgetKitChatFont] linkColor:linkColor];
                }else{
                    slabel.attributedText =   [[NSAttributedString alloc] initWithString:@""];
                }
            }];
        }
        CGSize s = [slabel preferredSizeWithMaxWidth:viewWidth-70-45];
        cellHeight = cellHeight + s.height + 20;
    }
    
    return cellHeight + 10 ;
}

-(void)jumpWebPage:(UIButton *)sender{
    if (sobotConvertToString(morelink).length == 0) {
        return;
    }
    if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemLinkClick:type:obj:)]){
        [self.delegate cellItemLinkClick:sobotConvertToString(morelink) type:ZCChatCellClickTypeOpenURL obj:morelink];
    }
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
